FROM golang:1.21 as build

WORKDIR /app

COPY /catgpt ./

RUN go mod download

RUN  CGO_ENABLED=0 go build -o /var/app
EXPOSE 8080
CMD [ "/var/app" ]

FROM gcr.io/distroless/static-debian12:latest-amd64 as prod

WORKDIR /

COPY --from=build /var/app /app

EXPOSE 8080

USER nonroot:nonroot

CMD [ "/app" ]