FROM golang:1.16-alpine as builder

RUN apk add --no-cache git make bash

COPY version.txt /version.txt

ARG REPO=https://github.com/k8ssandra/cass-operator.git

RUN VERSION=$(cat /version.txt) \
    && git clone ${REPO} /src \
    && cd /src \
    && echo "Checkout tag $VERSION" \
    && if [ "$VERSION" != "main" ] && [ ! -z "$VERSION" ] ; then git checkout tags/${VERSION} -b ${VERSION} ; fi

RUN cd && git clone https://github.com/magefile/mage \
    && cd mage \
    && go run bootstrap.go \
    && cd .. && rm -rf mage

WORKDIR /src
RUN go mod download

RUN VERSION=$(git describe --tags --always --dirty) \
    && echo "Build version $VERSION" \
    && CGO_ENABLED=0 go build -o /operator -ldflags "-X main.version=$VERSION" ./operator/cmd/manager/

RUN mkdir -p /var/lib/cass-operator/ \
    && touch /var/lib/cass-operator/base_os

FROM scratch 

COPY --from=builder /var/lib/cass-operator /var/lib/cass-operator
COPY --from=builder /operator /operator

CMD [ "/operator" ]