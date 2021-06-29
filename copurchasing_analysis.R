#install.packages("igraph")
library(igraph)
library(dplyr)

products <- read.csv("products.csv",header = TRUE, sep = ",")
copur <- read.csv("copurchase.csv",header = TRUE, sep = ",")

#### 1 ####
# Delete products that are not books from “products” and “copurchase” files
# And then delete the books with salesrank >150,000 or salesrank = -1
books <- subset(products, products$group=='Book' 
                & products$salesrank <= 150000 
                & products$salesrank != -1)
books_copur <- subset(copur, copur$Source %in% books$id & copur$Target %in% books$id)

#### 2 ####
#	Create a variable named in-degree
# to show how many “Source” products people who buy “Target” products buy
# i.e. how many edges are to the focal product in “co-purchase” network.

g <- graph.data.frame(books_copur, directed = T)

in_degree <- degree(g, mode='in')
length(in_degree)

#### 3 ####
# Create a variable named out-degree
# to show how many “Target” products people who buy “Source” product also buy
# i.e., how many edges are from the focal product in “co-purchase” network.
out_degree <-degree(g, mode='out')
length(out_degree)


#### 4 ####
# Pick up one of the products (in case there are multiple) 
# with highest degree (in-degree + out-degree) and find its subcomponent
# i.e. all the products that are connected to this focal product. 

all_degree <- degree(g, mode='all')
max(all_degree)
max_degree <- which(all_degree == max(all_degree))

# From this point on, you will work only on this subcomponent. 
sub1 <- subcomponent(g, max_degree[1], mode = 'all') # product 4429 nodes
sub2 <- subcomponent(g, max_degree[2], mode = 'all') # product 33 nodes

#### 5 ####
# Visualize the subcomponent using iGraph, trying out different colors, 
# node and edge sizes and layouts, so that the result is most appealing. 
# Find the diameter, and color the nodes along the diameter. 
# Provide your insights from the visualizations.

# product 33
newg2 <- subgraph(g,sub2) 
g2_nodes <- V(newg2)$name

# diameter
diameter(newg2, directed = T, weights = NA)
d <- get_diameter(newg2, weights = NULL)
d # nodes that are in the diameter

V(newg2)$degree <- degree(newg2)
V(newg2)[diam]$size <- 6.5
V(newg2)$color <-"gold"
V(newg2)$color[d] <-"orange"
V(newg2)$label <- g2_nodes
plot.igraph(newg2, edge.arrow.size=.01,
     vertex.color=V(newg2)$color, vertex.frame.color="#555555",
     vertex.size=degree(newg2)*0.3, 
     vertex.label = ifelse(degree(newg2) > 50, V(newg2)$label ," "),
     main = "Product 33",layout=layout.kamada.kawai)

#### 6 ####
# Compute various statistics about this network (i.e. subcomponent), 
# including degree distribution, density, and centrality 
# (degree centrality, closeness centrality and between centrality), 
# hub/authority scores, etc. Interpret your results

# degree distribution
degree_distribution <- degree_distribution(newg2, cumulative = FALSE)
plot(x=0:max(all_degree), y=degree_distribution, pch=19, 
     cex=0.9, col="black", xlab="Degree", ylab="Frequency")

# density
edge_density(newg2, loops=F)

# degree centrality
degree_centralty <- degree(newg2, mode="all")
hist(degree_centralty, xlab = "number of degree")

in_degree2 <- degree(newg2, mode='in')
out_degree2 <- degree(newg2, mode='out')

# closeness centrality
closeness <- closeness(newg2, mode='all', weights=NA)

# between centrality
betweenness <- betweenness(newg2, directed='T', weights=NA)

# hub/authority scores
hs <- hub.score(newg2)$vector
as <- authority.score(newg2)$vector

statistic_frame <- as.data.frame(g2_nodes)
statistic_frame <- statistic_frame%>%
  mutate(degree = degree_centralty, closeness = closeness, betweenness = betweenness,
         hub= hs, authority = as)

colnames(statistic_frame)[1] <- "id"


#### 7 ####
# Create a group of variables containing the information of neighbors 
# that “point to” focal products.
# a.	Neighbors’ mean rating (nghb_mn_rating)
# b.	Neighbors’ mean salesrank (nghb_mn_salesrank)
# c.	Neighbors’ mean number of reviews (nghb_mn_review_cnt)
# Note: you may recall the functions in “dplyr” such as group_by, inner_join, summarize, mean, etc.

# books dataset with only IDs that appear in the subcoponant of product 33
sub_books <- subset(books,books$id %in% sub2$name)

neighbor_means <- inner_join(books_copur, sub_books,by = c("Target" = "id")) %>%
  group_by(Target) %>%
  summarize(nghb_mn_rating = mean(rating),
            nghb_mn_salesrank = mean(salesrank),
            nghb_mn_review_cnt = mean(review_cnt))


#### 8 ####
# Include the variables (taking logs where necessary) created in Parts 2-6 above
# into the “products” information and fit a Poisson regression to predict salesrank
# of all the books in this subcomponent using products’ own information and their
# neighbor’s information. Provide an interpretation of your results. 
# Note: Lower salesrank means higher sales. Data points in the network are related. 
# The performance of one node is influenced by the performance of its neighbors. 
# Also, it’s not necessary that all variables matter. 

poisson_data <- merge(sub_books,statistic_frame,by='id')
poisson_data <- full_join(poisson_data, neighbor_means, by = c("id" = "Target"))

poisson <- glm(salesrank ~ in_degree2 + out_degree2 + closeness + betweenness + 
                 hs + as + review_cnt + downloads + rating, family = "poisson", 
               data = poisson_data)
summary(poisson)
