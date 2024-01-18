FROM golang:1.21 as build

WORKDIR /app

COPY . /app/

RUN go mod download
RUN go vet -v
RUN go test -v

RUN  CGO_ENABLED=0 go build -o /var/app


FROM gcr.io/distroless/static-debian12 as prod

WORKDIR /app

COPY --from=build /var/app ./

EXPOSE 8080

#USER nonroot:nonroot

ENTRYPOINT [ "./app" ]