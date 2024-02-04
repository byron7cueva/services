# This Dockerfile uses separate build arguments instead of VARIANT
ARG BASE_IMAGE_VERSION_CODENAME=bookworm
FROM mcr.microsoft.com/devcontainers/base:${BASE_IMAGE_VERSION_CODENAME}

USER root
ENV JAVA_HOME /opt/java/openjdk
ENV PATH "${JAVA_HOME}/bin:${PATH}"
# Default to UTF-8 file.encoding
ENV LANG en_US.UTF-8