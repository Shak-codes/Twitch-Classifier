<h1 align="center">Twitch Classifier Report</h1>
<h3 align="center">By Shakir Rahman</h3>
<p align="center"><em>shaksafehaven@gmail.com</em></p>

&nbsp;&nbsp;&nbsp;&nbsp;**1. Introduction.** The following report aims to analyze the observable differences between individuals in different Twitch chats. Utilising message data from the five of: rdcgaming, rdcgamingtwo, rdcgamingthree, rdcgamingfour, and rdcgamingfive, we will commence with an exploratory data analysis(EDA). This EDA will explore the underlying relationships we wish to capture through sentiment analysis, followed by the identification of significant features, correlations, and preparing the dataset for modelling. Afterwards, we will develop several different models in order to predict the origin of concatenated chat messages and select the best performing model in terms of its performance on future data.

&nbsp;&nbsp;&nbsp;&nbsp;**2. Data.**<br>
&nbsp;&nbsp;&nbsp;&nbsp;***2.1. Twitch Overview.*** Before we dive into our data collection methods we must provide a quick overview of Twitch as a whole. Essentially, &nbsp;&nbsp;&nbsp;&nbsp;Twitch is a live streaming platform where creators can broadcast their content to viewers across the globe. While primarily for gaming, Twitch &nbsp;&nbsp;&nbsp;&nbsp;as a platform hosts creators in a variety of categories and allows for viewers to interact with the creator through the creator's channel in real &nbsp;&nbsp;&nbsp;&nbsp;time via Twitch's chat service. <br>

&nbsp;&nbsp;&nbsp;&nbsp;***2.2. Data Collection.*** Our analysis involves collecting message data from the creators at RDC. The group consists of many members but the &nbsp;&nbsp;&nbsp;&nbsp;five individuals we will focus on in our analysis are Mark, Desmond, Dylan, Leland, and Ben. These five members typically play games &nbsp;&nbsp;&nbsp;&nbsp;together on Twitch and livestream their gameplay through the channels RDCGaming, RDCGamingTwo, RDCGamingThree, RDCGamingFour, &nbsp;&nbsp;&nbsp;&nbsp;and RDCGamingFive. 

&nbsp;&nbsp;&nbsp;&nbsp;In terms of the chat messages collected, it's fairly rudimentary. Any message in these five chats, sent by a real person(not a robot), that &nbsp;&nbsp;&nbsp;&nbsp;doesn't include any links or commands will be collected. For each message, the following is recorded: the username of the sender, the &nbsp;&nbsp;&nbsp;&nbsp;message content itself, the Twitch channel the message originates from (which is then mapped to the individual streaming at the time. Ie. If &nbsp;&nbsp;&nbsp;&nbsp;Desmond is streaming on RDCGamingTwo, the message would belong to Desmond's chat), and finally the date the message was sent. 

&nbsp;&nbsp;&nbsp;&nbsp;There is a caveat to the above, being that message data is only collected when at least one of RDCGamingTwo, Three, Four, or Five are live &nbsp;&nbsp;&nbsp;&nbsp;alongside RDCGaming. The purpose behind this is derived from the fact that the RDCGaming channel often streams solo content unrelated &nbsp;&nbsp;&nbsp;&nbsp;to gaming. During these solo streams, the entire group is typically together in the same group call on the single channel. Consequently, it is &nbsp;&nbsp;&nbsp;&nbsp;infeasible to attribute a message in chat to any member, and the tone in the chat is representative of the collective dynamic of the different &nbsp;&nbsp;&nbsp;&nbsp;communities rather than highlighting each communities' individual quirks. On the other hand, when RDC play games together on stream, the &nbsp;&nbsp;&nbsp;&nbsp;secondary channels go live where each member streams their own point of view within the game. This method allows us to obtain data that &nbsp;&nbsp;&nbsp;&nbsp;reflects the behaviour of each community for the purpose of comparison and model generation. <br>

&nbsp;&nbsp;&nbsp;&nbsp;***2.3. Suspected Patterns.*** Given the above, it is natural to believe that the different communities surrounding each member would produce different patterns in the way they speak in chat. We wish to verify this through sentiment analysis. <br>
&nbsp;&nbsp;&nbsp;&nbsp;***2.4. Exploratory Data Analysis.*** <br>
&nbsp;&nbsp;&nbsp;&nbsp;****2.4.1. Output.**** <br>
&nbsp;&nbsp;&nbsp;&nbsp;****2.4.2. Features.**** <br>

&nbsp;&nbsp;&nbsp;&nbsp;**3. Methodology.**

&nbsp;&nbsp;&nbsp;&nbsp;**4. Results.**
