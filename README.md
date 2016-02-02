# DBA Functions and Tools
The aim of this project is to collate useful SQL functions and tools that can be dropped onto a server and provide immediate benefit.

The tools that are to be collated should be
 * Business agnostic - have some use regardless of business processes 
   
Any tools developed should include
 * comments that describe each step
 * descriptions of uncommon functions and stored procedures
 * work within a 2008 r2 plus environment

> any functions that are limited to a future/legacy version of SQL Server should be labelled clearly



Validation should be done of all code intially this will be done by submission to [Codereview.Stackexchange](http://codereview.stackexchange.com/) , in the future this will ideally be done in a shared forum.

## Concepts ##
**Red Tagging**

Red tagging is a tool from Lean Six Sigma project management. The idea is to sort your environment and remove anything extraneous, leaving only what is in use and valuable. I decided to try converting this to SQL so that I can see what stored procedures are being used and where. This way I can make an informed decision and have evidence for legacy code use/non use.

To set this up is onerous and requires code change so I would suggest only adding this:

 - You have a small environment
 - To a subset of procedures that you have targeted for review

The components of SQL Red Tagging are:

 - TBC