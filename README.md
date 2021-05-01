# Final App

This is a web service that allows users to perform Optical Character
Recognition (OCR) on uploaded files. The process is as follows:

1. The user uploads file to this web service
2. The file is saved on AWS S3
3. The user selects settings to preprocess the file
4. The file undergoes both preprocessing and OCR via the web service
5. The user downloads the file
6. The file is deleted from AWS S3 after an hour

As a web service, this product only offers a graphic user interface
for end users.

