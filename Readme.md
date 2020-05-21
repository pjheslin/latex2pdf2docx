# latex2pdf2docx

Latex2pdf2docx is yet another LaTeX to Microsoft Word converter.  Its conversion methodology is admittedly a rather bizarre and very ugly hack, but it works in some cases where all others fail.

The special feature of latex2pdf2docx is that it can handle arbitrarily complex TeX/LaTeX macros, including bibliographies and references to bibliographical items (but not math, as yet).  Its main drawback is that it requires a certain amount of manual fiddling.  So the best use case is a very complex scholarly manuscript which has been written in LaTeX but which the author is required to submit to a publisher as Word file(s).  In situations where a lengthy and complex document has to be converted only once, a comprehensive but somewhat fiddly solution may be quite acceptable.

I have used this method to convert two full-length book manuscripts ([this](https://shop.getty.edu/products/the-museum-of-augustus-the-temple-of-apollo-in-pompeii-the-portico-of-philippus-in-rome-and-latin-poetry-978-1606064214) and [this](https://global.oup.com/academic/product/propertius-greek-myth-and-virgil-9780199541577?cc=gb&lang=en&)) and many articles from LaTeX to Word.  I have not implemented any support for math mode, because I have no need for that myself.  But what I describe here is more a technique than a tool that will work out of the box for all situations; it should be easy to adapt to the needs of your own manuscript.  Please do contribute any of your extensions.

## How it works

There are many LaTeX to Word converters, and some of them are very good: they can handle all of the core LaTeX syntax.  In fact, in the final step of our process, we will use the wonderful [Pandoc](https://pandoc.org) to convert an intermediate, automatically generated LaTeX representation of our document to Word.

A limitation of all converters like Pandoc is that they can deal well with straight LaTeX syntax, but less well with dynamically generated context, like automatically generated bibliographies and bibliographical references.  That is because the only thing that can reliably parse TeX is the TeX engine itself.  So we take a different approach, which uses TeX to process our document, but outputting a form of LaTeX that Pandoc can convert to Word.

The key to how this converter works is in this intermediate step.  The text at this half-way stage is produced by TeX itself, so it can expand all the macros necessary to generate dynamic content.  But it embeds within that text a subset of LaTeX macros that can be converted to Word features by a converter like Pandoc.  

This intermediate step is a PDF document which contains all of the required auto-generated text, but which does not contain the formatting that we want.  Instead of representing that formatting visually, the text of the PDF document reproduces the original LaTeX macros that we want to convert to Word features.

What makes this work is the file latex2pdf2docx.sty.  This file redefines many common LaTeX macros so that, instead of formatting their output, they reproduce themselves in the output for conversion to Word at the next step.  I have only redefined the macros that I have needed, so you might need to add others.

## The Workflow

1.  Once you have a final version of your manuscript which is ready for final conversion to Word, you must change the fontloading commands in you LaTeX source so that the document uses one unicode font only (a font you have installed for use with LaTeX/XeTeX), without any ligatures or features like old-style figures.  

    For example, if you are using XeTeX and `fontspec`, you might say:

        \setromanfont[Mapping=tex-text,Ligatures=NoCommon]{Gentium}

     Run LaTeX again to make sure there are no errors or unexpected warnings.

2.  It may help to edit the preamble of your document to comment out formatting that has no hope of being supported by Pandoc. Copy the file `latex2pdf2docx.sty` from this repository to your LaTeX working directory.  Add this line to the start of your preamble:

        \usepackage{latex2pdf2docx}

3.  Run (pdf/Xe)LaTeX on the document and view the generated PDF.  Look at the text content of the document only (some of which, such as the bibliography, will be auto-generated); the PDF should not have any interesting formatting.  Read the text as LaTeX source code, destined for conversion to Word via Pandoc.  Check it for errors and make sure all of the features you wish to have converted are present as LaTeX macros.  If there are problems you may have to edit your source, or edit `latex2pdf2docx.sty` to add additional macros to the ones it redefines.  Repeat this step until your PDF consists of text that is clean LaTeX source code.

4.  You now need to extract the text from the PDF document.  The command-line tool `pdftotext` works well on Linux, but I have had problems with it on a Mac.  Alternatively, you can open the PDF in a reader application, select all and copy.  Then paste the text into a text editor.  On a Mac, I have found that Preview.app or Skim works well for this.  You may have to experiment; some readers balk at copying large amounts of text at one go.

5.  Save the extracted text in a new file with a `.tex` extension, such as `myfile.tex` (but do not run LaTeX on this file).  Sometimes Pandoc has had problems processing files with very long lines, so you may have to run the file through the `fmt` command-line tool to fix this.

6.  Run Pandoc on the .tex file to convert it to Word, like so:

        pandoc -o myfile.docx myfile.tex

7.  Use Word to perform final tweaks of the appearance of the Word file and fix table layouts, etc.

## To-do

* Math mode
* Page references
