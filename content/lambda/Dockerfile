FROM public.ecr.aws/lambda/python:3.9

RUN yum update -y

COPY lambda.py ${LAMBDA_TASK_ROOT}

CMD [ "lambda.lambda_handler" ]
