import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import scipy.stats

#------------------------------------------------------------------------------
#------------------------Loading Data into Python------------------------------
#------------------------------------------------------------------------------
##use the panda's library built in methods to read a csv file into a dataframe 
##we pass sep = ',' argument not because of a necessity, but as a common practice
##
dataFile = 'StudentData2.csv'
studentdf = pd.read_csv(dataFile,sep=',')
#------------------------------------------------------------------------------
#------------------------------Data Cleaning Steps-----------------------------
#------------------------------------------------------------------------------
##Prints the structure of the dataframe
studentdf.info()
##student.gender.dtype() is another method to get the dtype


##turn gender, section into category type
studentdf.gender = studentdf.gender.astype('category')
studentdf.section = studentdf.section.astype('category')


##turn id into string
studentdf.id = studentdf.id.astype('object')


##removing rows that are not 6 digits in length using
##panda's drop method
studentdf= studentdf.drop(studentdf[studentdf['id'] > 700000].index)
studentdf= studentdf.drop(studentdf[studentdf['id'] <600000].index)


##removing rows with genders other than 1 or 2
##this is achived using basic python boolean indexing
## | is used because we're comparing two series that contain True and False values
##True and Falses and integers are things that can be combined bitwise
studentdf = studentdf[(studentdf['gender'] ==1) | (studentdf['gender']==2)]


## remove rows with age outside of 18 to 80 range
## achived using boolean indexing 
## & is used because equired bitwise and operator
studentdf[(studentdf['age'] <=80) & (studentdf['age'] >= 18)]


## remove all rows with missing values 
## achived using the panda's dropna() method
studentdf = studentdf.dropna()


##turn sat score into int dtype
studentdf.sat = studentdf.sat.astype('int')


## sat column has no other incorrect value
## section column has no other incorrect value
## final column has no other incorrect value
studentdf['sat']
studentdf['section']
studentdf['final']


## removing rows with incorrect project value
## achived using boolean indexing
studentdf = studentdf[(studentdf['project'] <=100)&(studentdf['project'] >=0)]


##number of rows in dataframe; there is 24 rows 
len(studentdf)
#------------------------------------------------------------------------------
#------------------------------Cleaned Data------------------------------------
#------------------------------------------------------------------------------
## printing out cleaned studentdf dataframe
cleaned_studentdf = studentdf
print('Clean Data: \n')
print(cleaned_studentdf)
#------------------------------------------------------------------------------
#----------------Exporting cleaned Data to OUTFILE.txt-------------------------
#------------------------------------------------------------------------------
## the following line of code creates the OUTFILE.txt file
## if name exists, it will get overwritten
file = open('OUTFILE.txt', 'w')
## Use dataframe's to_csv method to write dataframe to txt file 
cleaned_studentdf.to_csv(file, index = False, sep = ' ', header = None)
file.write('\n')
## cleaned_studentdf.to_csv('OUTFILE.txt') <-- works too
#------------------------------------------------------------------------------
#---------------------Calculating Statsitics and Figures-----------------------
#------------------------------------------------------------------------------
##Figure 1
##Normal probability plot for student gpa 
plt.figure()
scipy.stats.probplot(studentdf['gpa'],plot = plt)
plt.title('Normal Probability Plot for gpa')
##sample distribution looks approximately normal; normality assumption holds


## independent samples t-test between male and female's final score
## null hypothesis is that the two means are equal
## alternative hypothesis is that the two means arent equal
## therefore, this is a two tail test
female_final = studentdf[studentdf['gender'] == 2]['final']
male_final = studentdf[studentdf['gender'] == 1]['final']
t_score, two_tail_p_value = scipy.stats.ttest_ind(female_final, male_final)
## note  t = 1.63, but it really should be plus and minus 1.63 because
## two tail test; the p value is in terms of a two tail test
t_score = str(t_score)
two_tail_p_value = str(two_tail_p_value)
file.write('The t-score is: ')
file.write(t_score)
file.write('\n')
file.write('The two tail p value is: ')
file.write(two_tail_p_value)
file.write('\n')
file.write('The p value and t score shows that there is no significant difference'
      ' between the two sample means; we do not reject the null hypothesis')
file.write('\n\n')


## return key values for the linear regression line between students final and 
##project grade
x = cleaned_studentdf['final']
y = cleaned_studentdf['project']
linear_regression_values = scipy.stats.linregress(x,y)
r_value = str(linear_regression_values[2])
rsquare_value = str(linear_regression_values[2]**linear_regression_values[2])
## write r value and r square value to OUTFILE.txt
file.write('The r value is: ')
file.write(r_value)
file.write('\n')
file.write('This shows a strong positive linear correlation \n')
file.write('The r square value is: ')
file.write(rsquare_value)
file.write('\n')
file.write('This shows that the fitted regression line is a good fit for the data')


##ANOVA is the multiple-mean veresion of the independent samples t-test
##ANOVA analysis to determine if multiple means are the same or different
##There is not a significant difference between the section's final score means
sec_data = cleaned_studentdf.groupby('section')
F_statistic, P_value = scipy.stats.f_oneway(sec_data.get_group(1.0)['final'],
                    sec_data.get_group(2.0)['final'],
                    sec_data.get_group(3.0)['final'],
                    sec_data.get_group(4.0)['final'],
                    sec_data.get_group(5.0)['final'])
file.write('\n\nThe F-statistic is: ')
file.write(str(F_statistic))
file.write('\nand the p-value is: ')
file.write(str(P_value))
file.write('\nthe .6 p-value is greater than .05 alpha, so the null hypothesis is not'
      ' rejected \n')


##use panda's built in describe() method to get statistics on final grade, 
##project, gpa, and sat then write the output to file
stat_df = cleaned_studentdf[['gpa','sat','final','project']]
for data in stat_df:
    file.write('\n')
    file.write(data)
    file.write(' statistics:')
    stat_df[data].describe().to_csv(file,header = False, sep = ' ')
    ##compute the median of final grade, project grade, gpa, sat
    ##and write it to OUTFILE.txt
    file.write(data)
    file.write(' median is: ')
    file.write(str(np.median(stat_df[data])))
    file.write('\n')
    ## compute the variance of final grade, project grade,
    ## gpa and sat and write it to OUTFILE.txt
    file.write(data)
    file.write(' variance is: ')
    file.write(str(np.var(stat_df[data])))
    file.write('\n')
file.close()


##Figure 2
##creating boxplots to visualize the 5 section's final scores 
student_final_boxplot= cleaned_studentdf.boxplot(column = 'final', by = 'section')
student_final_boxplot.set_xlabel('Sections')
student_final_boxplot.set_ylabel('Values')
student_final_boxplot.get_figure().suptitle('')
student_final_boxplot.set_title('Final scores by Section')


#Figure 3
##Scatterplot between final score and project score using matplotlib
plt.figure()
plt.scatter(x,y,c = np.random.rand(24), alpha = .3, marker = 'd')
plt.xlabel('Project Grades')
plt.ylabel('Final Grades')
plt.title('Project vs Final Scatterplot')
#------------------------------------------------------------------------------
#-------------------------Creating Grade Feature and Barplot-------------------
#------------------------------------------------------------------------------
##grade binning using panda's cut method
cleaned_studentdf['binned'] = pd.cut(cleaned_studentdf.gpa,bins = 
                 [0.0, 2.0,2.5,3.0,3.5,4.0], 
                right = False, labels = ['F','D','C','B','A'])
grades_frequency = cleaned_studentdf.binned.value_counts()


##Figure 4
## bar plot created using grades_frequency series and pyplot method.
plt.figure()
plt.bar(grades_frequency.index, grades_frequency.values, color = 'rgby')
plt.title('Student Grades')
plt.xlabel('Grade Labels')
plt.ylabel('Frequency')







