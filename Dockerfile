
# Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

COPY pubspec.* ./
RUN flutter pub get

COPY . .

ARG CATALOGUE_API_URL
RUN flutter build web --release \
    --dart-define=CATALOGUE_API_URL=${CATALOGUE_API_URL}

# Serve the compiled web app
FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 10000

CMD ["nginx", "-g", "daemon off;"]
