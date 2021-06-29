# Copurchasing-Analysis-via-Network-Analysis
Team members : Cloris He, Joy Chen, Misha Khan, Ping-Chun Liu, Jialu Li    
Feb, 2021

This project is about Amazon’s co-purchase network; i.e., which products are purchased together on Amazon. There are two data files for this assignment: “products.csv” and “copurchase.csv”. “products.csv” contains the information about the products. “copurchase.csv” contains the co-purchase information (i.e., if people bought one product, then they also co-purchased the other). This is a directed graph, as explained below.     
    
The file “products.csv” has the following variables:    
•	**Id**: Product id (number 1, 2, ..., 262109)    
•	**title**: Name/title of the product    
•	**group**: Product group (Book, DVD, Video or Music etc.), in this assignment, we only work with the books group.    
•	**salesrank**: Amazon Salesrank (click the link to see the description of Salesrank)    
•	**rating**: User rating on a scale of 1 to 5     
•	**total** number of reviews: Total number of product reviews available on Amazon     
    
The file “copurchase.csv” has two variables, which are Product ID’s:    
•	**Source**: This is the focal product that was purchased     
•	**Target**: People who bought “Source” also purchased the Target product    

*Note that the edge between Source and Target is directed: Source -> Target.*
    
In this project we will complete the following steps, based on the two data sets provided:     
1.	Delete products that are not books from “products” and “copurchase” files.    
*Note: In social network analysis, it important to define the boundary of your work; in other words, the boundary of the network.*   
2.	Create a variable named in-degree, to show how many “Source” products people who buy “Target” products buy; i.e. how many edges are to the focal product in “co-purchase” network.
3.	Create a variable named out-degree, to show how many “Target” products people who buy “Source” product also buy; i.e., how many edges are from the focal product in “co-purchase” network.
4.	Pick up one of the products (in case there are multiple) with highest degree (in-degree + out-degree), and find its subcomponent, i.e., all the products that are connected to this focal product. From this point on, you will work only on this subcomponent. 
5.	Visualize the subcomponent using iGraph, trying out different colors, node and edge sizes and layouts, so that the result is most appealing. Find the diameter, and color the nodes along the diameter. Provide your insights from the visualizations.
6.	Compute various statistics about this network (i.e., subcomponent), including degree distribution, density, and centrality (degree centrality, closeness centrality and between centrality), hub/authority scores, etc. Interpret your results.
7.	Create a group of variables containing the information of neighbors that “point to” focal products. The variables include:    
a.	Neighbors’ mean rating (nghb_mn_rating),     
b.	Neighbors’ mean salesrank (nghb_mn_salesrank),     
c.	Neighbors’ mean number of reviews (nghb_mn_review_cnt)       
8.	Include the variables (taking logs where necessary) created in Parts 2-6 above into the “products” information and fit a Poisson regression to predict salesrank of all the books in this subcomponent using products’ own information and their neighbor’s information. Provide an interpretation of your results.    
*Note: Lower salesrank means higher sales. Data points in the network are related. The performance of one node is influenced by the performance of its neighbors. Also, it’s not necessary that all variables matter.*     
    
