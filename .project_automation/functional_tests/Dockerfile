FROM public.ecr.aws/codebuild/amazonlinux2-x86_64-standard:4.0
<<<<<<< before updating
ENV TERRAFORM_VERSION=1.5.0
ENV GO_VERSION=1.20.2
=======
ENV TERRAFORM_VERSION=1.7.4
>>>>>>> after updating
RUN cd /tmp && \
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin && chmod 755 /usr/local/bin/terraform