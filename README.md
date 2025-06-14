<h1 align="center">Twitch Classifier Report</h1>
<h3 align="center">By Shakir Rahman</h3>
<p align="center"><em>shakdevelops@gmail.com</em></p>

&nbsp;&nbsp;&nbsp;&nbsp;**1. Introduction.** The following report aims to analyze the observable differences between individuals in different Twitch chats. Utilising message data from the five of: rdcgaming, rdcgamingtwo, rdcgamingthree, rdcgamingfour, and rdcgamingfive, we will commence with an exploratory data analysis(EDA). This EDA will explore the underlying relationships we wish to capture through sentiment analysis, followed by the identification of significant features, correlations, and preparing the dataset for modelling. Afterwards, we will develop several different models in order to predict the origin of concatenated chat messages and select the best performing model in terms of its performance on future data.

&nbsp;&nbsp;&nbsp;&nbsp;**2. Data.**<br>
&nbsp;&nbsp;&nbsp;&nbsp;***2.1. Twitch Overview.*** Before we dive into our data collection methods we must provide a quick overview of Twitch as a whole. Essentially, Twitch is a live streaming platform where creators can broadcast their content to viewers across the globe. While primarily for gaming, Twitch as a platform hosts creators in a variety of categories and allows for viewers to interact with the creator through the creator's channel in real time via Twitch's chat service. <br>

&nbsp;&nbsp;&nbsp;&nbsp;***2.2. Data Collection.*** Our analysis involves collecting message data from the creators at RDC. The group consists of many members but the five individuals we will focus on in our analysis are Mark, Desmond, Dylan, Leland, and Ben. These five members typically play games together on Twitch and livestream their gameplay through the channels RDCGaming, RDCGamingTwo, RDCGamingThree, RDCGamingFour, and RDCGamingFive. 

&nbsp;&nbsp;&nbsp;&nbsp;In terms of the chat messages collected, it's fairly rudimentary. Any message in these five chats, sent by a real person(not a robot), that doesn't include any links or commands will be collected. For each message, the following is recorded: the username of the sender, the message content itself, the Twitch channel the message originates from (which is then mapped to the individual streaming at the time. Ie. If Desmond is streaming on RDCGamingTwo, the message would belong to Desmond's chat), and finally the date the message was sent. 

&nbsp;&nbsp;&nbsp;&nbsp;There is a caveat to the above, being that message data is only collected when at least one of RDCGamingTwo, Three, Four, or Five are live alongside RDCGaming. The purpose behind this is derived from the fact that the RDCGaming channel often streams solo content unrelated to gaming. During these solo streams, the entire group is typically together in the same group call on the single channel. Consequently, it is infeasible to attribute a message in chat to any member, and the tone in the chat is representative of the collective dynamic of the different communities rather than highlighting each communities' individual quirks. On the other hand, when RDC play games together on stream, the secondary channels go live where each member streams their own point of view within the game. This method allows us to obtain data that reflects the behaviour of each community for the purpose of comparison and model generation. <br>

&nbsp;&nbsp;&nbsp;&nbsp;***2.3. Data Preprocessing.*** Our dataset includes chat messages from the period of May 14th to May 28th 2025. Given the course of the eight streams over this time period, we have obtained about 250K individual messages between the five twitch channels. Before the data can be fit for modelling we need to preprocess it so that we have clear observations and features that a model can learn from. We begin by shuffling the original message data observations in order to have two files `messages.csv` and `messages_shuffled.csv`. We further filter out all messages from the aforementioned files that mention the names: Ben, Mark, Dylan, Desmond, and Leland, to create `messages_filtered.csv` and `messages_shuffled_filtered.csv`. The purpose for these four unique files are to be explored following the explanation of our preprocessing steps.

&nbsp;&nbsp;&nbsp;&nbsp;We loop through each Twitch channel `channel` and define a variable `observation` as an empty string. We then loop through each message `msg` sent in `channel` and perform `observation += f"{msg}. "`. This continues for each subsequent message until `observation` is a string of at least `X`(where `X` is one of 500, 1000, and 1500) characters. Once this condition has been met, we find the counts of each pairwise alphabetical character within `observation`, that is, we find the number of times `aa`, `ab`, `ac`, ..., `az`, ..., `zz` is present within `observation`. Finally, we write the details of this observation to a csv file with all 676 pairwise letter combinations as their own separate column, a column that stores the concatenated messages `observation` and finally the Twitch channel these messages originate from. Following the recording of this observation, we reset `observation` back to an empty string and repeat the process until all messages sent in `channel` have been processed. 

&nbsp;&nbsp;&nbsp;&nbsp;The above leaves us with a total of twelve files, six for unfiltered data and another six for filtered data, stored in `rdc/data/regular` and `rdc/data/filtered` respectively. 

&nbsp;&nbsp;&nbsp;&nbsp;We decided to shuffle the raw `messages.csv` observations earlier because messages are inherently temporal data. Consecutive messages are not only reflective of the Twitch channel they originate from, but the specific moment or 'vibe' at the time they were sent. The worry is that the observations obtained above from just `messages.csv` will be littered with temporal influence and not be truly reflective of the channel's linguistic style. Hence we decided to work with both shuffled and unshuffled data so that we can understand the effect they have on our predictions. 

&nbsp;&nbsp;&nbsp;&nbsp;Furthermore, we want to utilise our models to gain an understanding of the pairwise combinations that are most pertinent in identifying a Twitch channel from a set of messages. As such, we created filtered versions of the datasets that removes all direct mentions of the streamer's name. Including these names will likely dominate the signal in our observations and result in models learning superficial identifiers as opposed to the actual linguistic distinctions that we desire. Similarly to the above, by having these distinct files we can examine the effect of training a model with the inclusion of streamer references and without.

&nbsp;&nbsp;&nbsp;&nbsp;***2.4. Exploratory Data Analysis.*** Given the above datasets, we now conduct an exploratory data analysis to understand any underlying patterns in our data, and make some final modifications so that we are ready for modelling.<br>

&nbsp;&nbsp;&nbsp;&nbsp;*2.4.1. Output.* Our response variable consists of 11253, 5643, and 3766 observations at the 500, 1000, and 1500 character level respectively. Plotting histograms of the response variable, we see that we generally have class imbalance and note that this must be accounted for during training. <br> 

&nbsp;&nbsp;&nbsp;&nbsp;*2.4.2. Features.* Regarding our features, we do not bother with histograms as the message data is erratic and won't follow any specific distributions. The same applies for outlier capping/removal alongside boxplots, which are disregarded as it is natural for us to believe that outliers are representative of linguistic patterns and that capping or removing them will erase meaningful data. We proceed by removing features with near-zero variance, applying z-score normalization and removing highly correlated features by way of correlation matrices. The results from the transformations in each dataset are displayed below.<br>

&nbsp;&nbsp;&nbsp;&nbsp;***2.5. Suspected Patterns.*** Given the above, it is natural to believe that the different communities surrounding each member would produce different patterns in the way they speak in chat. We wish to verify this through sentiment analysis. Aside from our conclusions regarding the sentiment analysis, we believe that the non shuffled data will have higher accuracy compared to the shuffled data due to overfitting regarding the temporal nature of the messages.<br>

&nbsp;&nbsp;&nbsp;&nbsp;**3. Methodology.** We proceed to fit the following models with their specifications and reasoning detailed below. We note that for all models, 

&nbsp;&nbsp;&nbsp;&nbsp;***3.1 Multinomial Logistic Regression.*** Multinomial logistic regression is a generalization of binary logistic regression that extends to multiple class scenarios. Essentially, given a response variable $Y \in \{1, \ldots, K\}$ and feature vector $x \in \mathbb{R}^p$ where $K$ is the total number of classes and $p$ is the number of features. The model estimates class probabilities as follows:
<p align="center">$P(Y = k \mid x) = \frac{\exp(\beta_k^T x)}{\sum_{j=1}^{K} \exp(\beta_j^T x)}, \quad \text{for} \quad k = 1, \ldots, K.$</p>

&nbsp;&nbsp;&nbsp;&nbsp;Where $\mathbb{B}_k \in \mathbb{R}^p$ is the weight vector for class $k$.

&nbsp;&nbsp;&nbsp;&nbsp;*3.1.1 Assumptions.* We also have that Multinomial logistic regression relies on three key assumptions, that being: 
- independence between observations
- the absence of high multicollinearity among features.

&nbsp;&nbsp;&nbsp;&nbsp;*3.1.2 Justification.* We fail to follow independence as we group our observations in the order they were sent in chat, which in turn makes our observations temporal. In order to mitigate this we decided to create another dataset where the messages are completely shuffled prior to the creation of the observations. While this isn't elimination of the violation, it is mitigation making the data much more suitable for the Multinomial model. Regarding high multicollinearity between features, this has already been accounted for in our Exploratory Data Analysis in which we removed any features where high multicollinearity occured. Hence satisfied.

&nbsp;&nbsp;&nbsp;&nbsp;Given that both assumptions have been adressed well in our Exploratory Data Analysis, we expect the Multinomial Logistic Regression model to perform competitively amongst the other models in terms of prediction performance. Moreover, the Multinomial Logistic Regression model has the additional benefit of interpretability. This will allow us to gain crucial insight into the features crucial for predictions, and provides insight on the types of messages that characterize a particular Twitch chat.

&nbsp;&nbsp;&nbsp;&nbsp;*3.1.2 Fitting.* To fit this model, 

&nbsp;&nbsp;&nbsp;&nbsp;***3.2 Linear Discriminant Analysis.*** Linear Discriminant Analysis is a generative model which assumes that the conditional distribution of each class is multivariate Gaussian with:
<p align="center">$X \mid Y = k \sim \mathcal{N}(\mu_k, \Sigma)$</p>

&nbsp;&nbsp;&nbsp;&nbsp;Where $\mu_h$ is the class mean and $\Sigma$ is the shared covariance matrix. Furthermore, the above paves the way for the following decision rule:
<p align="center">$\delta_k(x) = x^T \Sigma^{-1} \mu_k - \frac{1}{2} \mu_k^T \Sigma^{-1} \mu_k + \log \pi_k$</p>

&nbsp;&nbsp;&nbsp;&nbsp;*3.2.1 Assumptions.* The Linear Discriminant Analysis model only operates correctly when the few assumptions are met as explained below:
- Normality: The features for each class follow a gaussian distribution 
- All classes share the same covariance structure
- The observations are independently and identically distributed

&nbsp;&nbsp;&nbsp;&nbsp;*3.2.2 Justification.* Regarding the justification for using LDA for our scenario, we can confidently say that our data does not adhere to all the assumptions that LDA requires. More specifically, the covariance assumption is likely broken in our dataset due to the fact that pairwise letter frequencies are inherently sparse due to linguistic patterns in the English language. This leads to data that is not normally distributed, in fact the data would be heavily skewed. Furthermore, as we are looking to analyze the different linguistic patterns among the various Twitch chats, we would also expect differing covariance matrices as a result.

&nbsp;&nbsp;&nbsp;&nbsp;Additionally, we cannot say that the data is independently and identically distributed. Twitch chat messages are a temporal data structure, groups of messages will have different patterns depending on the timestamp during the stream. Intuitively, hype moments will have a different tone from sad or even funny moments, and that tone shift will reflect in the messages sent in chat. Hence not identical. Regarding independence, we fail this for the same reasons as the MLR model, but note that the shuffled dataset does indeed help mitigate this.

&nbsp;&nbsp;&nbsp;&nbsp;Overall, while our data doesnt follow the explicit assumptions for an LDA model to perform well, LDA models are robust and still perform decently well even when it's assumptions are mildly violated. We include LDA as a baseline model to pose the question "Can we still classify well under violated assumptions?" Even if we cant meet all the assumptions, this model may still capture useful patterns.

&nbsp;&nbsp;&nbsp;&nbsp;***3.3 Naive Bayes.*** Naive Bayes is another generative classification model rooted in Bayes' Theorem. The mathematical formulation is as follows:
<p align="center">$P(Y = k \mid X = x) \propto P(Y = k) \prod_{j=1}^p P(X_j = x_j \mid Y = k)$</p>

&nbsp;&nbsp;&nbsp;&nbsp;where $P(Y=k)$ is the class prior, $P(X_j=x_j | Y=k)$ is the class conditional distribution given the $j^{\text{th}}$ feature. Furthermore, while our features aren't necessarily continous(technically discrete since any feature belongs to the set of natural numbers), we consider them to be continuous since we have a wide enough range. This leads to: $X_j | Y = k$ being modeled as $X_j \mid Y = k \sim \mathcal{N}(\mu_{jk}, \sigma_{jk}^2)$

&nbsp;&nbsp;&nbsp;&nbsp;*3.3.1 Assumptions.* Naive Bayes is a model that requires the following assumptions to be met:

- Independence of observations
- Class-conditional Normality
- Conditional Independence

&nbsp;&nbsp;&nbsp;&nbsp;*3.3.2 Justification.* While Independence and class conditional normality fail for the same reasons as mentioned in MLR & LDA, we find that conditional independence fails for a similar but different reason. Precisely, conditional independence means that the features `aa`, `ab`, ..., `zz` are independently irregardless of class. This is unrealistic given our data because letter pairs in the English language are not independent. If `t` occurs often then `h` is likely to occur along with it. There are hundreds of examples of this phenomenon due to the structure of the English language and so our data clearly violates conditional independence.

&nbsp;&nbsp;&nbsp;&nbsp;In terms of jutifiability, we cannot go without saying that our data doesnt strongly adhere to any of the assumptions. While this doesnt bode well for our model, we also note that Naive Bayes performs well in high dimensional settings like ours. This is because the model drastically reduces the number of features required for estimation. Instead of estimating the full joint distribution, it gets by perfectly well by estimating the marginal distributions for each feature. This leads to lower variance which is essential for high dimensional data.

&nbsp;&nbsp;&nbsp;&nbsp;Despite the clear violation of assumptions in our dataset, Naive Bayes is a hopeful attempt at appeasing the high dimensional space we are working in. The emphasis on the marginal distribution allows for efficient computations and yields robust performance despite the assumption violations. While imperfect, the model will serve as a baseline of performance for models built on data that clearly violates the assumptions the model relies upon.

&nbsp;&nbsp;&nbsp;&nbsp;***3.4 K-Nearest Neighbours.*** K-Nearest Neighbours is a non-parametric machine learning model for classification. The model makes predictions based on a given set of features by referencing the K nearest observations in the test set to the given set of features. To formalize the prediction for a given point $x$, we have...
<p align="center">$\hat{Y}(x) = \arg\max_{k} \sum_{i \in \mathcal{N}_k(x)} \mathbf{1}\{Y_i = k\}$</p>

&nbsp;&nbsp;&nbsp;&nbsp;Where $\mathcal{N}_k(x)$ is the set of indices that correspond to the $K$ closest points to $x$ in the train set.

&nbsp;&nbsp;&nbsp;&nbsp;*3.4.1 Assumptions.* K-Nearest Neighbours makes very few assumptions about the dataset it is working with. Aside from it assuming that similar points are close in feature space, the only other assumption is relies on is the fact that the number of observations should be vastly greater than the number of features.

&nbsp;&nbsp;&nbsp;&nbsp;*3.4.2 Justification.* Our data presents a challenge regarding similar points being close in feature space. In practice, the assumption holding in our data is questionable at best. Many messages are very short which comes with noise and they're also ambiguous semantically. Essentially, this leads to messages from different chats sharing similar feature space. Furthermore, the n-grams approach here can fail to capture contextual meaning. A set of messages may only differ by a few characters but belong to completely different channels. This weakens the results of distance based metrics which KNN heavily relies on. Finally, given that we have 676 observations, we only have 6000-11000 observations depending on the concatenation size(500, 1000, or 1500). While this is much larger than the observations, it is only by a factor of 10 to 15, preferably we would like to have enough data for the observations to be nearly one hundred times more than the number of features.

&nbsp;&nbsp;&nbsp;&nbsp;Considering the above, it is logical to believe that the K-Nearest Neighbours model will perform very poorly. Not only do we fail to meet the sparse assumptions, but the n-gram approach doesn't translate well to our Twitch chat scenario. Consequently, this model should in theory perform even worse than our Naive Bayes model and should be the gold standard in the worst model we create this session.

&nbsp;&nbsp;&nbsp;&nbsp;***3.5 Support Vector Machines*** Support Vector Machines are the first discriminative classifier we use. The model constructs a hyperplane in our high dimensional space that optimally separates classes with the largest possible margin. In simple binary classification, the optimization problem is as follows:
<p align="center">$\min_{w, b, \xi} \frac{1}{2} \|w\|^2 + C \sum_{i=1}^n \xi_i \quad \text{subject to} \quad y_i(w^T x_i + b) \geq 1 - \xi_i, \; \xi_i \geq 0,$</p>

&nbsp;&nbsp;&nbsp;&nbsp;Where $w$ and $b$ are parameters of the separating hyperplane, $\xi$ is the slack parameter, with $C$ being the regularization parameter. However, we are working with multiclass level classification, and so our optimization problem extends the above as shown below:
<p align="center">$\hat{Y}(x) = \arg\max_k \, f_k(x)$</p>

&nbsp;&nbsp;&nbsp;&nbsp;With $f_k(x)$ is the decision function output from the one-vs-rest Support Vector Machine which, intuitively, was trained to recognize class $k$ from the rest.

&nbsp;&nbsp;&nbsp;&nbsp;*3.5.1 Assumptions.* Similar to K-Nearest Neighbours, Support Vector Machines have a single assumption which is margin seperability: an existing boundary that separates the classes. Otherwise, Support Vector Machines' performance rely on the kernal selected and feature scaling. Linear SVMs assume the data is approximately linearly separable while non-linear kernals can transform the data to a higher dimension for separation purposes.

&nbsp;&nbsp;&nbsp;&nbsp;*3.5.2 Justification.* Given our extremely high dimensional data, a linear kernal would be perfect for our scenario. In this scenario we experience the "blessing of dimensionality" in which high dimensional spaces often become more separable, with linear boundaries proving very effective. Furthermore, the sparse nature of the observations due to many pairwise letters being completely irrelevant aligns well with SVM's use of regularization techniques.

&nbsp;&nbsp;&nbsp;&nbsp;All in all, we expect the SVM models to perform extremely competitively. Our data seems practically designed to be fit by an SVM model. The high dimensionality, sparsity of features are all handled efficiently by the model. This model should end up as a top contender in regards to prediction performance.

&nbsp;&nbsp;&nbsp;&nbsp;***3.6 Extreme Gradient Boosting*** Extreme Gradient Boosting is an ensemble based learning method based on gradient-boosted decision trees. The model trains numerous trees in a sequential manner, where each subsequent tree attempts to fix the residual errors of the previous trees. The training is done by maximizing the following:
<p align="center">$\mathcal{L}(\phi) = \sum_{i=1}^n \ell(y_i, \hat{y}_i) + \sum_{t=1}^T \Omega(f_t)$</p>

&nbsp;&nbsp;&nbsp;&nbsp;Where $\ell$ is the loss function(which is differentiable), $\hat{y}_i$ is the predicted value, $f_t$ is the $t^{\text{th}}$ regression tree and finally $\Omega(f) = \gamma T + \frac{1}{2} \lambda \sum_{j=1}^T w_j^2$

&nbsp;&nbsp;&nbsp;&nbsp;*3.6.1 Assumptions.* Once again, this method relies on very few assumptions, those being below:
- No high multicollinearity
- Minimal heavy noise

&nbsp;&nbsp;&nbsp;&nbsp;*3.6.2 Justification.* Our Exploratory Data Analysis stage already removed features that caused high multicollinearity, hence we have accounted for this assumptions within our data. However, our data struggles when it comes to minimizing noise. We've talked about it previously, and it remains the case that the nature of Twitch chat messages are very noisy. Messages are often very short, contextual to the very specific section of the stream and these introduce semantic noise. This can lead to the trees overfitting to the noisy data and picking up on irrelevant patterns. Luckily however, regularization techniques can offset this by way of shallow tree depth, subsampling to reduce variability and a low learning rate combined with many boosting rounds for gradual refinement.

&nbsp;&nbsp;&nbsp;&nbsp;To conclude our findings with Extreme Gradient Boosting, we believe it will provide competitive prediction capabilities. Unlike the SVM scenario, our data is not perfectly handled by an XGB model. However, the regularization techniques that the model provides allows for robust performance and fine tuning for the ability to capture meaningful patterns that contribute to overall predictability.

&nbsp;&nbsp;&nbsp;&nbsp;***3.7 Random Forests*** Random Forests are another ensemble based learning method that trains multiple decision trees on bootstrapped samples of the data. Each split in the tree is built by selecting a random subset of features, and selecting a feature that maximizes a certain criterian from said subset, all in order to reduce correlation between the varying trees. The final prediction is obtained by considering the majority vote between the trees. Formalizing this notion, we have the following formula:
<p align="center">$\hat{Y}(x) = \text{majority\_vote}\left\{T_b(x)\right\}_{b=1}^B$</p>

&nbsp;&nbsp;&nbsp;&nbsp;*3.7.1 Assumptions.* Random Forests do not operate under any formal assumptions about the data. The only caveat is that the trees are susceptible to a decrease in performance when the dataset is very noisy.

&nbsp;&nbsp;&nbsp;&nbsp;*3.7.2 Justification.* Despite the noisy dataset, Random Forests have many appealing qualities. They naturally handle categorical, sparse and non linear interactions amongst features, which is a given with Twitch chat messages. Furthermore, the use of bootstrapped samples and randomized feature subsits minimize overfitting ensuring that the trees don't take the same split every generation. Aside from this, we must ensure to properly tune the models so that they do not overfit to any of the noise, otherwise leading to suboptimal performance.

&nbsp;&nbsp;&nbsp;&nbsp;At the end of the day, Random Forests are models that provide a blanace between flexibility and robustness. Their minimal data preprocessing steps and ability to model complex data without any formal assumptions are a huge positive. While they may not match the performance of the SVM models due to the noisy data that requires careful fine tuning to handle, their generalization ability makes them a valuable baseline model for what we can consider good prediction performance.

&nbsp;&nbsp;&nbsp;&nbsp;***3.8 Neural Networks*** Neural Networks are models composed of layers through interconnected units. Each layer operates on a linear transformation followed by a nonlinear activation function. Given $L$ hidden layers, the feedforward network is as shown below:
<p align="center">$a^{(0)} = x \\
a^{(\ell)} = g^{(\ell)}(W^{(\ell)} a^{(\ell-1)} + b^{(\ell)}), \quad \text{for } \ell = 1, \dots, L \\
\hat{y} = \text{softmax}(W^{(L+1)} a^{(L)} + b^{(L+1)})
$</p>

&nbsp;&nbsp;&nbsp;&nbsp;*3.8.1 Assumptions.* Just like the other non-parametric methods, Neural Networks do not make any formal assumptions of the data. Aside from the need for many observations, Neural Networks are very robust and will perform well if tuned properly.

&nbsp;&nbsp;&nbsp;&nbsp;*3.8.2 Justification.* Neural Networks seem to be an especially strong choice given that they're adept at learning complex, non-linear decision boundaries. This allows them to understand extremely sophisticated patterns across multiple layers which can be a massive benefit in predictive capabilities. The only caveat is the immense number of observations required for a Neural Network to generalize the patterns as opposed to overfitting. In our dataset, while we have a modest number of observations it may very well not be large enough for the network to avoid overfitting.

&nbsp;&nbsp;&nbsp;&nbsp;To conclude, we believe the Neural Network model's performance will align in the center prediction wise when compared to all other models. Given the capabilities to learn sophisticated patterns, this meshes perfectly with our complex dataset, however the lack of an expansive enough observation count results in mitigating the aforementioned benefits.

&nbsp;&nbsp;&nbsp;&nbsp;**4. Results.**
