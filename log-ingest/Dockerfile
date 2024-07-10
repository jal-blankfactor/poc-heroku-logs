ARG NODE_VERSION=20.9.0
FROM public.ecr.aws/bitnami/node:${NODE_VERSION} as builder

WORKDIR /dist
COPY package.json ./
RUN npm install

FROM public.ecr.aws/lambda/nodejs:20
WORKDIR ${LAMBDA_TASK_ROOT}

COPY --from=builder ./dist ./
COPY ./src ./

CMD [ "index.handler" ]
