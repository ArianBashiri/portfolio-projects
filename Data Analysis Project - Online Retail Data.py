#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd


# In[2]:


df_original = pd.read_csv(r"/Users/Arianbashiri/Documents/Data Analysis Project/OnlineRetail.csv", encoding='ISO-8859-1')
df_original


# In[3]:


df = df_original
df


# In[4]:


df.head(10)


# # Cleaning the dataset

# ### Missing values

# In[5]:


# Finding amount of missing values in each column
df.info()


# In[6]:


df.isnull().sum()


# In[7]:


missing_values = df[df.isnull().any(axis=1)]
missing_values.head(20)


# In[8]:


# Changing the display of rows
pd.set_option('display.max.rows', 20)


# ### Finding and removing duplicates

# In[9]:


df.duplicated().sum()


# In[10]:


df[df.duplicated()]


# In[11]:


df = df.drop_duplicates()
df


# In[12]:


# Exploring the data
filtered_df = df[df['StockCode'] == '85123A']
filtered_df


# In[13]:


#Exploring dataset
filtered_df['Description'].unique()


# In[14]:


#Exploring dataset
pd.set_option('display.max_rows', 50)
df[df['Description'] == '?']


# ### Removing rows where 'UnitPrice' = 0.0

# In[15]:


df[df['UnitPrice'] == 0.0]


# In[16]:


df = df[df['UnitPrice'] != 0.0]
df


# In[17]:


# Checking to see if the rows were removed
df[df['UnitPrice'] == 0.0]


# In[18]:


# Exploring dataset
df[df['StockCode'] == '22139']


# In[19]:


# Exploring dataset
df[df['Quantity'] <= 0]


# ### Changing country name 

# In[20]:


#Changing 'EIRE' to 'Ireland'
df['Country'] = df['Country'].replace('EIRE', 'Ireland')
df[df['Country'] == 'Ireland']


# ### Removing rows with invalid countries

# In[21]:


#Removing rows where country = 'Unspecified' and 'European Community'
df = df[df['Country'] != 'Unspecified'] 
df = df[df['Country'] != 'European Community']


# ### Converting datatypes

# In[22]:


df.info()


# In[23]:


# Converting column 'InvoiceDate' to datetime
df['InvoiceDate'] = pd.to_datetime(df['InvoiceDate'])


# In[24]:


# Converting column 'CustomerID' to integer
# df['CustomerID'].astype(int) did not work as it contained missing values
df['CustomerID'] = df['CustomerID'].astype(pd.Int64Dtype())


# In[25]:


df.info()


# In[26]:


df[df['CustomerID'].isnull()]


# ### Identifying outliers

# In[27]:


df.boxplot(figsize = (20,10))


# In[127]:


df[df['Quantity'] > 6000]


# In[29]:


df[df['UnitPrice'] > 17000]


# # Data exploration

# In[43]:


df


# In[39]:


import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt


# ### Total spending by country

# In[53]:


#Calculating the total spending for each invoice
df['TotalSpending'] = df['Quantity'] * df['UnitPrice']

#Grouping by country and sorting by highest to lowest
country_spending = df.groupby('Country')['TotalSpending'].sum().reset_index()
country_spending = country_spending.sort_values(by='TotalSpending', ascending=False)
country_spending


# In[48]:


#Visualization using seaborn with log scale
plt.figure(figsize=(10, 6))
sns.barplot(x='Country', y='TotalSpending', data=country_spending, palette='viridis')
plt.yscale('log')  #Set the y-axis to log scale
plt.title('Total Spending by Country (Log Scale)')
plt.xlabel('Country')
plt.ylabel('Total Spending (Log Scale)')

#Rotating x-axis labels for better readability
plt.xticks(rotation=45, ha='right')

plt.show()


# ### Top 10 products

# In[49]:


top_products = df.groupby('Description')['Quantity'].sum().reset_index()
top_products = top_products.sort_values(by='Quantity', ascending=False).head(10)

#Visualization using seaborn
plt.figure(figsize=(12, 6))
sns.barplot(x='Description', y='Quantity', data=top_products, palette='viridis')
plt.title('Top 10 Most Sold Products')
plt.xlabel('Product Description')
plt.ylabel('Total Quantity Sold')
plt.xticks(rotation=45, ha='right')

plt.show()


# ### Distribution of loyal and common customers

# In[56]:


#Criterias for loyal customers
loyalty_criteria = {
    'Frequency': 3, #Customer should have made at least 3 purchases
    'TotalMonetaryValue': 100 #Customer should have a total monetary value spent greater than $100
}
#Calculate customer metrics
df['TotalPrice'] = df['Quantity'] * df['UnitPrice']
customer_metrics = df.groupby('CustomerID').agg({
    'TotalPrice': 'sum',
    'InvoiceDate': 'nunique'
}).reset_index()

#Renaming columns
customer_metrics.columns = ['CustomerID', 'TotalMonetaryValue', 'Frequency']

#Creating segments based on criteria
loyal_customers = customer_metrics[(customer_metrics['TotalMonetaryValue'] >= loyalty_criteria['TotalMonetaryValue']) &
                                  (customer_metrics['Frequency'] >= loyalty_criteria['Frequency'])]

common_customers = customer_metrics[~customer_metrics['CustomerID'].isin(loyal_customers['CustomerID'])]

#Displaying segments
print("Loyal customers:")
print(loyal_customers)

print("Common customers:")
print(common_customers)


# In[ ]:





# In[59]:


#Count of loyal and common customers
loyal_count = loyal_customers.shape[0]
common_count = common_customers.shape[0]

#Creating a pie chart
labels = ['Loyal Customers', 'Common Customers']
sizes = [loyal_count, common_count]
colors = ['green', 'red']

fig, ax = plt.subplots()
ax.pie(sizes, labels=labels, autopct='%1.1f%%', colors=colors, startangle=90)
ax.axis('equal')
ax.set_title('Distribution of loyal and common customers')

plt.show()



# In[85]:


#removing and ordering columns
remove = ['TotalSpending']
df = df[df.columns.difference(remove)]
desired = ['InvoiceNo', 'InvoiceDate', 'Country', 'CustomerID', 'StockCode', 'Description', 'Quantity', 'UnitPrice', 'TotalPrice']
df = df.loc[:, desired]
df


# ### Overall sales

# In[123]:


#Creating a new column with only the date (not time)
df['Date'] = df['InvoiceDate'].dt.date

#Aggregating total sales from each day 
daily_sales = df.groupby('Date')['TotalPrice'].sum()

#Sales trend over time
plt.figure(figsize=(10,6))
plt.plot(daily_sales.index, daily_sales.values, label='Total Sales')
plt.title('Overall Sales Over Time')
plt.xlabel('Date')
plt.ylabel('Total Sales')
plt.legend()
plt.show()


# ### Sales Trend

# In[132]:


daily_total_price = df.groupby('Date')['TotalPrice'].sum().reset_index()
plt.figure(figsize=(10,6))
sns.regplot(x=daily_total_price.index, y='TotalPrice', data=daily_total_price, ci=None, line_kws={"color": "red"})
plt.title('Total Sales Trend Over Time')
plt.xlabel('Date')
plt.ylabel('Total Sales')
plt.show()


# In[ ]:




