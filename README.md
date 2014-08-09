Zula Newsstand App Type
=======================

Newsstand is an app type for ZulaMobile. The app aims to display 
issues in pdf or HTML5 format and feature the app in Apple Newsstand

Component Types
===============

LibraryComponent
----------------

Displays PDF or HTML5 issue covers on a shelf. Displays the issue contents upon
tapping on image. If issue is a PDF, downloads it locally.

Additional Features
===================

Adverts
-------

This app type is designed to display full-screen adverts

Creating a new Project Using Newsstand App Type
===============================================

 * Follow the steps in ZulaLibrary README.
 * Add following to `Pods-NewsletterLibrary-prefix.pch` file:

    #import "ZulaLibrary.h"
    #import "DDLog.h"
    
        // notifications
    #import "SMNotifications.h"
    #define kNotificationIssueDownloadDidFinish @"kNotificationIssueDownloadDidFinish"
    #define kNotificationIssueDownloadDidStart @"kNotificationIssueDownloadDidStart"
    
    #ifdef DEBUG
    static const int ddLogLevel = LOG_LEVEL_VERBOSE;
    #else
    static const int ddLogLevel = LOG_LEVEL_WARN;
    #endif
