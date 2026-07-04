import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class DocumentViewer extends StatelessWidget {
  final Map<String, dynamic> documents;
  const DocumentViewer({super.key, required this.documents});

  bool _isImage(String? ext) {
    if (ext == null) return false;
    return ['jpg', 'jpeg', 'png'].contains(ext.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final valid = <String, Map<String, dynamic>>{};
    for (final entry in documents.entries) {
      final val = entry.value;
      if (val != null &&
          val is Map<String, dynamic> &&
          val['data'] != null) {
        valid[entry.key] = val;
      }
    }

    if (valid.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('No documents uploaded',
            style: TextStyle(
                color: Colors.white38, fontSize: 13)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: valid.entries.map((entry) {
        final label = entry.key
            .replaceAll('_', ' ')
            .split(' ')
            .map((w) => w.isEmpty
                ? ''
                : w[0].toUpperCase() + w.substring(1))
            .join(' ');
        final doc = entry.value;
        final base64Data = doc['data'] as String;
        final extension = doc['extension'] as String?;
        final fileName =
            doc['fileName'] as String? ?? label;
        final isImg = _isImage(extension);

        return _DocTile(
          label: label,
          fileName: fileName,
          base64Data: base64Data,
          isImage: isImg,
          extension: extension ?? '',
        );
      }).toList(),
    );
  }
}

class _DocTile extends StatefulWidget {
  final String label;
  final String fileName;
  final String base64Data;
  final bool isImage;
  final String extension;
  const _DocTile({
    required this.label,
    required this.fileName,
    required this.base64Data,
    required this.isImage,
    required this.extension,
  });
  @override
  State<_DocTile> createState() => _DocTileState();
}

class _DocTileState extends State<_DocTile> {
  bool _expanded = false;

  Future<void> _openFile() async {
    final mimeType = widget.isImage
        ? 'image/${widget.extension.toLowerCase()}'
        : 'application/pdf';
    final dataUrl =
        'data:$mimeType;base64,${widget.base64Data}';
    final uri = Uri.parse(dataUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri,
          mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2D2D4E)),
      ),
      child: Column(children: [
        // Header
        GestureDetector(
          onTap: () =>
              setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF16162A),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(10),
                topRight: const Radius.circular(10),
                bottomLeft:
                    Radius.circular(_expanded ? 0 : 10),
                bottomRight:
                    Radius.circular(_expanded ? 0 : 10),
              ),
            ),
            child: Row(children: [
              Icon(
                widget.isImage
                    ? Icons.image_outlined
                    : Icons.picture_as_pdf_outlined,
                color: widget.isImage
                    ? const Color(0xFF6C63FF)
                    : Colors.redAccent,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(widget.label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ),
              Icon(
                _expanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Colors.white38,
                size: 18,
              ),
            ]),
          ),
        ),

        // Expanded content
        if (_expanded) ...[
          if (widget.isImage)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    base64Decode(widget.base64Data),
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                          'Could not display image',
                          style: TextStyle(
                              color: Colors.redAccent)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _openFile,
                  icon: const Icon(Icons.open_in_new,
                      size: 14,
                      color: Color(0xFF6C63FF)),
                  label: const Text('Open in new tab',
                      style: TextStyle(
                          color: Color(0xFF6C63FF),
                          fontSize: 12)),
                ),
              ]),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                const Icon(Icons.picture_as_pdf,
                    color: Colors.redAccent, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                    Text(widget.fileName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13)),
                    const Text('PDF Document',
                        style: TextStyle(
                            color: Colors.white38,
                            fontSize: 11)),
                  ]),
                ),
                ElevatedButton.icon(
                  onPressed: _openFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.open_in_new,
                      color: Colors.white, size: 14),
                  label: const Text('Open PDF',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13)),
                ),
              ]),
            ),
        ],
      ]),
    );
  }
}