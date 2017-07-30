python-mkdoc
============

An amazing helper script to generate pydoc for your python projects.

Running the script ( *mkpydoc.sh* ) from the root directory of your project will generate pydoc for all module components (and they will link to eachother) into the "doc" directory, as well as creating an index.html -- ready to zip up and upload to pythonhosted.org via pypi


Installation
------------

*mkpydoc.sh* has an optional dependency on AdvancedHTMLParser ( https://github.com/kata198/AdvancedHTMLParser or https://pypi.python.org/pypi/AdvancedHTMLParser ).

It is STRONGLY recommended you have this package installed, otherwise *mkpydoc.sh* will NOT be able to prepare the documentation for web-hosting (they will contain links to the local filesystem). You CAN still generate docs easily with this script without AdvancedHTMLParser.


Either use "install.sh" in the project root to install *mkpydoc.sh* to the local system. You may also choose to just add the *mkpydoc.sh* script to your project's root directory. More on this is covered below


How to Use
----------

There are two ways to use *mkpydoc.sh*

The first step is to nativage to your project directory ( e.x. the directory you clone from git, NOT your package dir )


**Local Install**

These instructions are for those who have run "install.sh" or otherwise installed *mkpydoc.sh* script onto the local system, such as in /usr/bin.

* Run *mkpydoc.sh NAME* where "NAME" is your package directory. So, for example, if I checked out the "python-subprocess2" git repo, I would run *mkpydoc.sh subprocess2* within that directory.

**Local Copy**

These instructions are for those who do NOT have *mkpydoc.sh* installed locally, but rather have a copy checked in with the source.

You CAN still provide the argument ( as with the "Local Install" instructions ), however if you check it in with your source code,

it is recommended that you modify the line:


	DEFAULT_PROJECT_NAME="YOUR_PROJECT_DIR_HERE"

to match your module's root directory. This will allow you to run *mkpydoc.sh* without arguments, and generate pydoc for the local project.


What it does
------------

*mkpydoc.sh* will scan the provided package directory and all subdirs and gather all .py files.

It will then invoke pydoc against all of these files in one go, which enables the various documents to reference and link to eachother.

Following pydoc generation, the script will "clean up" the resulting output. It will convert the local filesystem paths to relative web-safe links. This both improves security (by not exposing your filesystem structure and potentially username as well), allows the pydoc documents to be hosted online, and ensures that the links actually work from a browser.

All of the generated HTML files will be placed in the directory "doc" at the root level of your project.

A symlink will be created from "index.html" -> MODULE/\_\_init\_\_.py where "MODULE" is the root package directory you provided. This is required for submitting to pythonhosted and provides a sane "starting point" when viewing the documents.


Further Actions
---------------

After generating the pydoc, you can prepare it for upload to pythonhosted.org (via pypi.python.org) with the following:

1 Navigate into the "doc" directory

2 Execute *zip doc.zip \*.html*

3 Navigate to pypi.python.org and login. On the sidebar, select your project. Click "releases" at the top. At the bottom is a form where you can upload the "doc.zip" you created above


You may also want to consider adding the following line to your *MANIFEST.in*


	recursive-include doc *.html

to include the pydoc documentation in the source distribution


