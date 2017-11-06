# MG-GY-9753 | Business Analytics | AirBnB Country Prediction

### Background

![logo](http://www.kagay-an.com/wp-content/uploads/2015/10/Airbnb-Logo.jpeg)

Airbnb is a community marketplace where guests can book living accommodations from a list of verified hosts. Membership to the 
site is completely free and there is no cost to post a listing. Using a targeted user interface designed to narrow down 
traveling preferences, Airbnb offers an attractive, cost-saving alternative to traditional hotel bookings and vacation home
rentals. 

Upon finding a desired listing, guests are prompted to sign up for membership, which provides access to contact the 
host directly as well as provide payment information for a request. Only once the host accepts the transaction and the guest 
checks in is the credit card charged, along with a 6-12% transaction fee from Airbnb.

The process is similarly simple for hosts, who 3 receive a notification once a guest indicates interest in a particular 
listing and have the option to approve or deny the transaction. Once the listing is booked, the host receives the payment and 
Airbnb takes a 3% transaction fee.

### The Challenge 

Design a model that will predict where will a new guest book their first travel experience. By
accurately predicting where a new user will book their first travel experience, Airbnb can share
more personalized content with their community, decrease the average time to first booking,
and better forecast demand. 

In building this model, you will need to consider the following:

● Data size: Some datasets are big (more than 1M variables). Consider reducing the
dataset to a random sample of 10% to run experiments. In addition, you will need to
join datasets using “user id”

● Data quality: Some numerical and categorical values are missing. You can replace
missing values with the media or mean. Alternative, you can eliminate the missing
values by subsetting your dataset. Both approaches have tradeoff.

● Multiclass Model: To solve this, you need to build a “multi-class classification” model.
This means you will need several classification to predict countries. Some approaches
may be:

1. Break up your problem into one classifier for new booking followed by
classifiers by each destination

2. Use Random Forest

3. Use the CARET package in R



