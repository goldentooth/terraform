function handler(event) {
  var response = {
    statusCode: 301,
    statusDescription: 'Moved Permanently',
    headers: {
      "location": { "value": "https://clog.goldentooth.net" }
    }
  };
  return response;
}
