class OfferResponse {
  final String sdp;
  final List<IceServer> iceServers;
  OfferResponse({required this.sdp, required this.iceServers});
}

class IceServer {
  final String url;
  final String? username;
  final String? credential;
  IceServer({required this.url, this.username, this.credential});
}
