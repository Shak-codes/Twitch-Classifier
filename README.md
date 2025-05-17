<h1 align="center">Twitch Classifier Report</h1>
<h3 align="center">By Shakir Rahman</h3>
<p align="center"><em>shaksafehaven@gmail.com</em></p>

&nbsp;&nbsp;&nbsp;&nbsp;**1. Introduction.** The following report aims to analyze the observable differences between individuals in different Twitch chats. Utilising message data from the five of: rdcgaming, rdcgamingtwo, rdcgamingthree, rdcgamingfour, and rdcgamingfive, we will commence with an exploratory data analysis(EDA). This EDA will explore the underlying relationships we wish to capture through sentiment analysis, followed by the identification of significant features, correlations, and preparing the dataset for modelling. Afterwards, we will develop several different models in order to predict the origin of concatenated chat messages and select the best performing model in terms of its performance on future data.

&nbsp;&nbsp;&nbsp;&nbsp;**2. Data.**<br>
&nbsp;&nbsp;&nbsp;&nbsp;***2.1. Twitch Overview.*** Before we dive into our data collection methods we must provide a quick overview of Twitch as a whole. Essentially, &nbsp;&nbsp;&nbsp;&nbsp;Twitch is a live streaming platform where creators can broadcast their content to viewers across the globe. While primarily for gaming, Twitch &nbsp;&nbsp;&nbsp;&nbsp;as a platform hosts creators in a variety of categories and allows for viewers to interact with the creator through the creator's channel in real &nbsp;&nbsp;&nbsp;&nbsp;time via Twitch's chat service. <br>

&nbsp;&nbsp;&nbsp;&nbsp;***2.2. Data Collection.*** Our analysis involves collecting message data from the creators at RDC. The group consists of many members but the &nbsp;&nbsp;&nbsp;&nbsp;five individuals we will focus on in our analysis are Mark, Desmond, Dylan, Leland, and Ben. These five members typically play games &nbsp;&nbsp;&nbsp;&nbsp;together on twitch and livestream their gameplay through the channels RDCGaming, RDCGamingTwo, RDCGamingThree, RDCGamingFour, &nbsp;&nbsp;&nbsp;&nbsp;and RDCGamingFive. 

&nbsp;&nbsp;&nbsp;&nbsp;In terms of the chat messages collected, it's fairly rudimentary. Any message in these five chats, sent by a real person(not a robot), that &nbsp;&nbsp;&nbsp;&nbsp;doesn't include any links or commands will be collected. The exact data that will be obtained per message is the username of the individual &nbsp;&nbsp;&nbsp;&nbsp;that sent the message, the message content itself, the Twitch channel the message originates from, and finally the date the message was &nbsp;&nbsp;&nbsp;&nbsp;sent. The only caveat to the above is that message data is only collected when at least one of rdcgamingtwo, rdcgamingthree, &nbsp;&nbsp;&nbsp;&nbsp;rdcgamingfour, or rdcgamingfive are live alongside rdcgaming. This is due to the fact that sometimes, only rdcgaming goes live and all five &nbsp;&nbsp;&nbsp;&nbsp;of Mark, Desmond, Dylan, Leland, and Ben will appear on said stream. <br>
&nbsp;&nbsp;&nbsp;&nbsp;***2.3. Suspected Patterns.*** <br>
&nbsp;&nbsp;&nbsp;&nbsp;***2.4. Exploratory Data Analysis.*** <br>
&nbsp;&nbsp;&nbsp;&nbsp;****2.4.1. Output.**** <br>
&nbsp;&nbsp;&nbsp;&nbsp;****2.4.2. Features.**** <br>

&nbsp;&nbsp;&nbsp;&nbsp;**3. Methodology.**

&nbsp;&nbsp;&nbsp;&nbsp;**4. Results.**
