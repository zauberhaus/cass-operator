
FROM alpine as builder

RUN apk update \ 
    && apk add binutils

COPY ./build /build
COPY detect.sh /

RUN /detect.sh

RUN mkdir -p /var/lib/cass-operator/ \
    && touch /var/lib/cass-operator/base_os

FROM scratch 

COPY --from=builder /var/lib/cass-operator /var/lib/cass-operator
COPY --from=builder /operator /operator

CMD [ "/operat