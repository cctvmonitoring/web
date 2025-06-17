// import 'dart:ui';

// class DetectionBox {
//   final int classId;
//   final double confidence;
//   final Rect bbox;

//   DetectionBox(this.classId, this.confidence, this.bbox);

//   factory DetectionBox.fromJson(Map<String, dynamic> json) {
//     return DetectionBox(
//       json['class_id'],
//       json['confidence'],
//       Rect.fromLTRB(
//         json['bbox'][0].toDouble(),
//         json['bbox'][1].toDouble(),
//         json['bbox'][2].toDouble(),
//         json['bbox'][3].toDouble(),
//       ),
//     );
//   }
// }

import 'dart:ui';

class DetectionBox {
  final int classId;
  final double confidence;
  final Rect bbox;

  DetectionBox(this.classId, this.confidence, this.bbox);
}
