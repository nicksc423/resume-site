# About this Project
This is the repository that contains everything for my website [nickcollins.link](https://nickcollins.link).  I made this site to not only display my resume but also to showcase some of the DevOps techniques that I have learned over the years.

It is broken up into two parts, the terraform directory which contains the terraform scripts that create everything in AWS and the content directory which contains the frontend static HTML pages and the backend which is a simple Python Lambda.

I serve the static content of this website with S3 and Cloudfront. S3 stores the static HTML pages and is configured in such a way that public access to the files is restricted so they can only be retrieved via Cloudfront. I use Cloudfront to cache and distribute the static content so I can safely and securely host this website with low latency and low costs.

At the bottom of the resume I have a simple view counter which acts as a simplified backend service. It is meant to simulate communicating to a backend service from the frontend web pages.  This is achieved through the combination AWS’s APIGateway, Lambda, and DynamoDB.  I use API Gateway to make a RESTful API that is able to execute my Lambda. My Lambda is a small bit of containerized Python code which when executed connects to my DynamoDB and runs a simple query to retrieve and increment the view count. This backend service is able to run without having any virtual machines to manage which makes it cheap and easy to use.

Finally, I needed a Domain and an SSL cert to host this site. Wanting to stay within the AWS environment I registered my domain with Route53, AWS’s DNS service. I also have a wildcard SSL cert registered within AWS so I can host the site using HTTPS.

With all this done I now have a full website! The front end is made up of static content stored in S3 and served via Cloudfront. The backend is an APIGateway fronting an AWS Lambda which in turn retrieves data from a DynamoDB table.

# Security 

Having built this whole website I wanted to put a special emphasis on security. Security has become more and more the domain of DevOps and I wanted to learn and educate myself about what tools I can use to increase my security posture.

One of the first things I did was to require commits to my repository to be signed using GPG. This ensures that the author is really the person whose name is on the commit and that the code change you see is really what the author wrote (i.e. it has not been tampered with).

Next I set up GitHub’s own automated code scanning, CodeQL. This will allow GitHub to scan the code in my repository and check it against any known CVEs to let me know if I have any unpatched vulnerabilities. I automatically run the code scan any time a pull request is merged to the main branch and fail the merge if security issues at level “High” or “Critical” are detected. To guard against dependency decay I automated the scan to run on a schedule once per month.

Then I wanted to sign the container image using Cosign. Cosign is a command line tool that allows you to sign containers so you can ensure that the container that you run is the exact container you expect and has not been modified. Cosign does this by uploading a .sig file to my container registry which can be verified using the public key uploaded with my Lambda code.

Following this I looked into creating a Software Bill of Materials (SBOM) using Syft. An SBOM is a manifest that lists all the packages shipped in your container image. Using Syft I make an “SBOM attestation file” which attests to what is included in the image. I sign this file with Cosign and upload it to the image repository as well. This attestation file can be verified by cosign which ensures that nothing else has been inserted into the image.

I also want to make sure that none of the other packages shipped in the container have any vulnerabilities as well. I use Grype, a vulnerability scanning tool by Anchore, which reads the SBOM and runs vulnerability scans against all packages included within it.

With all this completed I have secured the software supply chain. I can verify that the python container is exactly what I built using Cosign. Addionally, Cosign can verify the attestation file ensuring the container has only the expected packages. Using Grype I know that none of the dependencies within the container image have any significant vulnerabilities. Using GitHub's CodeQL scanning I know that anything I have added to the image does not have any significant vulnerabilities. CodeQL will automatically scan my repository once a month so I will also be alerted to any new vulnerabilies discovered.
