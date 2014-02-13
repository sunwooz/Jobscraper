Hacker News Job Search Engine
=============================

Features
========

* Search through the entire HN Job listing using multiple keywords
* Ordered from most recent to least

Version History
===============

Feb 13, 2014
------------

* Switched from sunspot:solr search to postgresql search vector indexes.


Problems
========

* Anyone can delete jobs

Future Features
===============

* Strip out sunspot:solr because I don't want to pay to use the production version on Heroku - Done 2/13/14
* User system + Roles
* Location grouping with different permutations of a word EX: nyc, new york, new york city as drop down select.
