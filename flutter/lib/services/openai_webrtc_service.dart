import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/webrtc_signalling.dart';

class OpenAIWebRTCService {
  RTCPeerConnection? _pc;
  RTCDataChannel? _dataChannel;
  MediaStream? _localStream;

  Future<RTCPeerConnection> _createConnection() async {
    final config = {'sdpSemantics': 'unified-plan'};
    _pc = await createPeerConnection(config);
    _dataChannel = await _pc!.createDataChannel('agentMessages', RTCDataChannelInit());
    return _pc!;
  }

  Future<RTCSessionDescription> createOffer() async {
    final pc = await _createConnection();
    _localStream = await navigator.mediaDevices.getUserMedia({'audio': true});
    for (var track in _localStream!.getTracks()) {
      pc.addTrack(track, _localStream!);
    }
    final offer = await pc.createOffer();
    await pc.setLocalDescription(offer);
    return offer;
  }

  Future<OfferResponse> sendOfferToOpenAI(RTCSessionDescription offer) async {
    final body = {
      'model': 'gpt-4o-mini-realtime',
      'webrtc_offer': offer.sdp,
      'audio_specs': {'encoding': 'opus', 'sample_rate': 24000}
    };
    final resp = await http.post(
      Uri.parse('https://api.openai.com/v1/realtime/sessions'),
      headers: {
        'Authorization': 'Bearer ${dotenv.env['OPENAI_API_KEY']}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    final data = jsonDecode(resp.body);
    final ice = (data['ice_servers'] as List).map(
      (e) => IceServer(
        url: e['urls'][0],
        username: e['username'],
        credential: e['credential'],
      ),
    );
    return OfferResponse(sdp: data['answer'], iceServers: ice.toList());
  }

  Future<void> applyAnswer(OfferResponse answer) async {
    await _pc?.setRemoteDescription(
        RTCSessionDescription(answer.sdp, 'answer'));
    // ICE servers are included when creating the connection; candidates may be
    // added later via standard WebRTC signalling if provided.
  }

  RTCDataChannel? get dataChannel => _dataChannel;
  RTCPeerConnection? get connection => _pc;
  MediaStream? get localStream => _localStream;
}
