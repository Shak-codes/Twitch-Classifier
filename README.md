<h1 align="center">Twitch Classifier Report</h1>
<h3 align="center">By Shakir Rahman</h3>
<p align="center"><em>shaksafehaven@gmail.com</em></p>

&nbsp;&nbsp;&nbsp;&nbsp;**1. Introduction.** The following report aims to analyze the observable differences between individuals in different Twitch chats. Utilising message data from the five of: rdcgaming, rdcgamingtwo, rdcgamingthree, rdcgamingfour, and rdcgamingfive, we will commence with an exploratory data analysis(EDA). This EDA will explore the underlying relationships we wish to capture through sentiment analysis, followed by the identification of significant features, correlations, and preparing the dataset for modelling. Afterwards, we will develop several different models in order to predict the origin of concatenated chat messages and select the best performing model in terms of its performance on future data.

&nbsp;&nbsp;&nbsp;&nbsp;**2. Data.**<br>
&nbsp;&nbsp;&nbsp;&nbsp;***2.1. Twitch Overview.*** Before we dive into our data collection methods we must provide a quick overview of Twitch as a whole. Essentially, Twitch is a live streaming platform where creators can broadcast their content to viewers across the globe. While primarily for gaming, Twitch as a platform hosts creators in a variety of categories and allows for viewers to interact with the creator through the creator's channel in real time via Twitch's chat service. <br>

&nbsp;&nbsp;&nbsp;&nbsp;***2.2. Data Collection.*** Our analysis involves collecting message data from the creators at RDC. The group consists of many members but the five individuals we will focus on in our analysis are Mark, Desmond, Dylan, Leland, and Ben. These five members typically play games together on Twitch and livestream their gameplay through the channels RDCGaming, RDCGamingTwo, RDCGamingThree, RDCGamingFour, and RDCGamingFive. 

&nbsp;&nbsp;&nbsp;&nbsp;In terms of the chat messages collected, it's fairly rudimentary. Any message in these five chats, sent by a real person(not a robot), that doesn't include any links or commands will be collected. For each message, the following is recorded: the username of the sender, the message content itself, the Twitch channel the message originates from (which is then mapped to the individual streaming at the time. Ie. If Desmond is streaming on RDCGamingTwo, the message would belong to Desmond's chat), and finally the date the message was sent. 

&nbsp;&nbsp;&nbsp;&nbsp;There is a caveat to the above, being that message data is only collected when at least one of RDCGamingTwo, Three, Four, or Five are live alongside RDCGaming. The purpose behind this is derived from the fact that the RDCGaming channel often streams solo content unrelated to gaming. During these solo streams, the entire group is typically together in the same group call on the single channel. Consequently, it is infeasible to attribute a message in chat to any member, and the tone in the chat is representative of the collective dynamic of the different communities rather than highlighting each communities' individual quirks. On the other hand, when RDC play games together on stream, the secondary channels go live where each member streams their own point of view within the game. This method allows us to obtain data that reflects the behaviour of each community for the purpose of comparison and model generation. <br>

&nbsp;&nbsp;&nbsp;&nbsp;***2.3. Data Preprocessing.*** Our dataset includes chat messages from the period of May 14th to May 28th 2025. Given the course of the eight streams over this time period, we have obtained about 250K individual messages between the five twitch channels. Before the data can be fit for modelling we need to preprocess it so that we have clear observations and features that a model can learn from. We begin by shuffling the original message data observations in order to have two files `messages.csv` and `messages_shuffled.csv`. We further filter out all messages from the aforementioned files that mention the names: Ben, Mark, Dylan, Desmond, and Leland, to create `messages_filtered.csv` and `messages_shuffled_filtered.csv`. The purpose for these four unique files are to be explored following the explanation of our preprocessing steps.

We loop through each Twitch channel `channel` and define a variable `observation` as an empty string. We then loop through each message `msg` sent in `channel` and perform `observation += f"{msg}. "`. This continues for each subsequent message until `observation` is a string of at least `X`(where `X` is one of 500, 1000, and 1500) characters. Once this condition has been met, we find the counts of each pairwise alphabetical character within `observation`, that is, we find the number of times `aa`, `ab`, `ac`, ..., `az`, ..., `zz` is present within `observation`. Finally, we write the details of this observation to a csv file with all 676 pairwise letter combinations as their own separate column, a column that stores the concatenated messages `observation` and finally the Twitch channel these messages originate from. Following the recording of this observation, we reset `observation` back to an empty string and repeat the process until all messages sent in `channel` have been processed. 

The above leaves us with a total of twelve files, six for unfiltered data and another six for filtered data, stored in `rdc/data/regular` and `rdc/data/filtered` respectively. 

We decided to shuffle the raw `messages.csv` observations earlier because messages are inherently temporal data. Consecutive messages are not only reflective of the Twitch channel they originate from, but the specific moment or 'vibe' at the time they were sent. The worry is that the observations obtained above from just `messages.csv` will be littered with temporal influence and not be truly reflective of the channel's linguistic style. Hence we decided to work with both shuffled and unshuffled data so that we can understand the effect they have on our predictions. 

Furthermore, we want to utilise our models to gain an understanding of the pairwise combinations that are most pertinent in identifying a Twitch channel from a set of messages. As such, we created filtered versions of the datasets that removes all direct mentions of the streamer's name. Including these names will likely dominate the signal in our observations and result in models learning superficial identifiers as opposed to the actual linguistic distinctions that we desire. Similarly to the above, by having these distinct files we can examine the effect of training a model with the inclusion of streamer references and without.

&nbsp;&nbsp;&nbsp;&nbsp;***2.4. Exploratory Data Analysis.*** Given the above datasets, we now conduct an exploratory data analysis to understand any underlying patterns in our data, and make some final modifications so that we are ready for modelling.<br>

&nbsp;&nbsp;&nbsp;&nbsp;*2.4.1. Output.* Our response variable consists of 11253, 5643, and 3766 observations at the 500, 1000, and 1500 character level respectively. Plotting histograms of the response variable, we see that we generally have class imbalance and note that this must be accounted for during training. <br> 

&nbsp;&nbsp;&nbsp;&nbsp;*2.4.2. Features.* Regarding our features, we do not bother with histograms as the message data is erratic and won't follow any specific distributions. The same applies for outlier capping/removal alongside boxplots, which are disregarded as it is natural for us to believe that outliers are representative of linguistic patterns and that capping or removing them will erase meaningful data. We proceed by removing features with near-zero variance, applying z-score normalization and removing highly correlated features by way of correlation matrices. The results from the transformations in each dataset are displayed below.<br>

&nbsp;&nbsp;&nbsp;&nbsp;***2.5. Suspected Patterns.*** Given the above, it is natural to believe that the different communities surrounding each member would produce different patterns in the way they speak in chat. We wish to verify this through sentiment analysis. Aside from our conclusions regarding the sentiment analysis, we believe that the non shuffled data will have higher accuracy compared to the shuffled data due to overfitting regarding the temporal nature of the messages.<br>

&nbsp;&nbsp;&nbsp;&nbsp;**3. Methodology.** We proceed to fit the following models with their specifications and reasoning detailed below. We note that for all models, 

&nbsp;&nbsp;&nbsp;&nbsp;***3.1 Multinomial Logistic Regression.*** Multinomial logistic regression is a generalization of binary logistic regression that extends to multiple class scenarios. Essentially, given a response variable $Y \in \{1, \ldots, K\}$ and feature vector $x \in \mathbb{R}^p$ where $K$ is the total number of classes and $p$ is the number of features. The model estimates class probabilities as follows:
<p align="center">$P(Y = k \mid x) = \frac{\exp(\beta_k^T x)}{\sum_{j=1}^{K} \exp(\beta_j^T x)}, \quad \text{for} \quad k = 1, \ldots, K.$</p>

Where $\mathbb{B}_k \in \mathbb{R}^p$ is the weight vector for class $k$.

&nbsp;&nbsp;&nbsp;&nbsp;*3.1.1 Assumptions.* We also have that Multinomial logistic regression relies on three key assumptions, that being: linear separability in the transformed log-odds space; independence of irrelevant alternatives; and no perfect multicollinearity among features.

&nbsp;&nbsp;&nbsp;&nbsp;*3.1.2 Fitting.* To fit this model, 

&nbsp;&nbsp;&nbsp;&nbsp;***3.2 Linear Discriminant Analysis.*** Linear Discriminant Analysis is a generative model which assumes that the conditional distribution of each class is multivariate Gaussian with:
<p align="center">$X \mid Y = k \sim \mathcal{N}(\mu_k, \Sigma)$</p>

Where $\mu_h$ is the class mean and $\Sigma$ is the shared covariance matrix. Furthermore, the above pave the way for the following decision rule:
<p align="center">$\delta_k(x) = x^T \Sigma^{-1} \mu_k - \frac{1}{2} \mu_k^T \Sigma^{-1} \mu_k + \log \pi_k$</p>

&nbsp;&nbsp;&nbsp;&nbsp;***3.3 Naive Bayes.*** Naive Bayes is another generative classification model rooted in Bayes' Theorem. The mathematical formulation is as follows:
<p align="center">$P(Y = k \mid X = x) \propto P(Y = k) \prod_{j=1}^p P(X_j = x_j \mid Y = k)$</p>

where $P(Y=k)$ is the class prior, $P(X_j=x_j | Y=k)$ is the class conditional distribution given the $j^{\text{th}}$ feature. Furthermore, while our features aren't necessarily continous(technically discrete since any feature belongs to the set of natural numbers), we consider them to be continuous since we have a wide enough range. This leads to: $X_j | Y = k$ being modeled as $X_j \mid Y = k \sim \mathcal{N}(\mu_{jk}, \sigma_{jk}^2)$

&nbsp;&nbsp;&nbsp;&nbsp;***3.4 K-Nearest Neighbours.*** K-Nearest Neighbours is a non-parametric machine learning model for classification. The model makes predictions based on a given set of features by referencing the K nearest observations in the test set to the given set of features. To formalize the prediction for a given point $x$, we have...
<p align="center">$\hat{Y}(x) = \arg\max_{k} \sum_{i \in \mathcal{N}_k(x)} \mathbf{1}\{Y_i = k\}$</p>

Where $\mathcal{N}_k(x)$ is the set of indices that correspond to the $K$ closest points to $x$ in the train set.

&nbsp;&nbsp;&nbsp;&nbsp;***3.5 Support Vector Machines*** Support Vector Machines are the first discriminative classifier we use. The model constructs a hyperplane in our high dimensional space that optimally separates classes with the largest possible margin. In simple binary classification, the optimization problem is as follows:
<p align="center">$\min_{w, b, \xi} \frac{1}{2} \|w\|^2 + C \sum_{i=1}^n \xi_i \quad \text{subject to} \quad y_i(w^T x_i + b) \geq 1 - \xi_i, \; \xi_i \geq 0,$</p>

Where $w$ and $b$ are parameters of the separating hyperplane, $\xi$ is the slack parameter, with $C$ being the regularization parameter. However, we are working with multiclass level classification, and so our optimization problem extends the above as shown below:
<p align="center">$\hat{Y}(x) = \arg\max_k \, f_k(x)$</p>

With $f_k(x)$ is the decision function output from the one-vs-rest Support Vector Machine which, intuitively, was trained to recognize class $k$ from the rest.

&nbsp;&nbsp;&nbsp;&nbsp;***3.6 Extreme Gradient Boosting*** Extreme Gradient Boosting is an ensemble based learning method based on gradient-boosted decision trees. The model trains numerous trees in a sequential manner, where each subsequent tree attempts to fix the residual errors of the previous trees. The training is done by maximizing the following:
<p align="center">$\mathcal{L}(\phi) = \sum_{i=1}^n \ell(y_i, \hat{y}_i) + \sum_{t=1}^T \Omega(f_t)$</p>

Where $\ell$ is the loss function(which is differentiable), $\hat{y}_i$ is the predicted value, $f_t$ is the $t^{\text{th}}$ regression tree and finally $\Omega(f) = \gamma T + \frac{1}{2} \lambda \sum_{j=1}^T w_j^2$

&nbsp;&nbsp;&nbsp;&nbsp;***3.7 Random Forests*** Random Forests are another ensemble based learning method that trains multiple decision trees on bootstrapped samples of the data. Each split in the tree is built by selecting a random subset of features, and selecting a feature that maximizes a certain criterian from said subset, all in order to reduce correlation between the varying trees. The final prediction is obtained by considering the majority vote between the trees. Formalizing this notion, we have the following formula:
<p align="center">$\hat{Y}(x) = \text{majority\_vote}\left\{T_b(x)\right\}_{b=1}^B$</p>

&nbsp;&nbsp;&nbsp;&nbsp;***3.8 Neural Networks*** Neural Networks are models composed of layers through interconnected units. Each layer operates on a linear transformation followed by a nonlinear activation function. Given $L$ hidden layers, the feedforward network is as shown below:
<p align="center">$a^{(0)} = x \\
a^{(\ell)} = g^{(\ell)}(W^{(\ell)} a^{(\ell-1)} + b^{(\ell)}), \quad \text{for } \ell = 1, \dots, L \\
\hat{y} = \text{softmax}(W^{(L+1)} a^{(L)} + b^{(L+1)})
$</p>

&nbsp;&nbsp;&nbsp;&nbsp;**4. Results.**
