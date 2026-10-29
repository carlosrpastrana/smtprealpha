import 'package:flutter/material.dart';

class CentroAyudaScreen extends StatelessWidget {
  const CentroAyudaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0056D2)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Centro de Ayuda',
          style: TextStyle(
            color: Color(0xFF0056D2),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preguntas Frecuentes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Respuestas rápidas sobre la seguridad alimentaria en SMT Libre de Gluten.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            _buildFaqTile(
              pregunta: '¿Cómo funciona la alerta de contaminación cruzada?',
              respuesta:
                  'Cuando un local acumula 5 o más reportes comunitarios indicando contaminación cruzada, la app activa una alerta preventiva visual para advertir a los comensales.',
            ),
            _buildFaqTile(
              pregunta: '¿Qué significa el distintivo "100% GF"?',
              respuesta:
                  'Indica que el establecimiento elabora exclusivamente productos libres de gluten, eliminando por completo el riesgo de contacto con harinas o derivados de TACC.',
            ),
            _buildFaqTile(
              pregunta: '¿Cómo puedo proponer un nuevo restaurante o tienda?',
              respuesta:
                  'Puedes escribirnos por los canales de soporte con la dirección y nombre del lugar. Nuestro equipo auditará los protocolos antes de publicarlo.',
            ),
            _buildFaqTile(
              pregunta: '¿Qué hacer ante una intoxicación o reacción celíaca?',
              respuesta:
                  'Prioriza siempre la atención médica. Luego, registra una reseña señalando "Contaminación cruzada" para proteger al resto de la comunidad.',
            ),

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF3FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.support_agent_outlined,
                    color: Color(0xFF0056D2),
                    size: 36,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '¿Necesitas más ayuda?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Escríbenos a soporte@smtlibredegluten.com',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF003E9A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqTile({required String pregunta, required String respuesta}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          pregunta,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF1E1E1E),
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(
            respuesta,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
