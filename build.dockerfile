# DON'T UPDATE TO node:14-bullseye-slim, see #372.
FROM centos:7 AS build
WORKDIR /app

COPY . .

# split the sqlite install here, so that it can caches the arm prebuilt
# do not modify it, since we don't want to re-compile the arm prebuilt again
RUN curl -sL https://rpm.nodesource.com/setup_14.x | bash
RUN yum install -y python git gcc-c++ make nodejs


RUN npm install @mapbox/node-pre-gyp -g
RUN npm install --ignore-scripts
RUN npx node-pre-gyp install --build-from-source
RUN npm run test
RUN npx node-pre-gyp package

FROM centos:7 AS release
WORKDIR /app/build
# Copy app files from build layer
COPY --from=build /app/build /app/build

