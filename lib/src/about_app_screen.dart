import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre o App')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(Icons.favorite, color: Colors.pink, size: 72),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'BreakForLove',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                'Versão 1.0.0',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),

            // Introdução
            const Text(
              '💖 BreakForLove — Pausa para o Amor',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bem-vindo ao BreakForLove!\n'
                  'Um aplicativo criado para casais que desejam fortalecer o relacionamento, promovendo pausas conscientes no uso do celular e mais momentos de conexão real.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Objetivo
            const Text(
              '🌟 Objetivo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'O BreakForLove tem como missão ajudar casais a reduzirem o uso excessivo do celular, incentivando atividades offline, celebração de datas especiais e o cultivo de hábitos saudáveis a dois.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Funcionalidades
            const Text(
              '🛠️ Funcionalidades',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const FeatureItem(text: 'Checklist de Atividades', description: 'Crie, edite e marque atividades para fazerem juntos, como passeios, filmes ou experiências novas.'),
            const FeatureItem(text: 'Lembretes e Datas Especiais', description: 'Adicione e visualize datas importantes, como aniversários e eventos do casal.'),
            const FeatureItem(text: 'Timer de Desconexão', description: 'Use o temporizador para períodos sem celular, incentivando conversas e momentos offline.'),
            const FeatureItem(text: 'Perfil do Casal', description: 'Personalize informações do casal, como músicas, filmes favoritos e datas marcantes.'),
            const FeatureItem(text: 'Temas Personalizáveis', description: 'Escolha entre vários temas de cores para deixar o app com a cara do casal.'),
            const SizedBox(height: 24),

            // Telas do App
            const Text(
              '🎨 Telas do App',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('- Home: Resumo do relacionamento, checklist e anotações rápidas.', style: TextStyle(fontSize: 16)),
            const Text('- Notificações: Timer de desconexão para incentivar pausas digitais.', style: TextStyle(fontSize: 16)),
            const Text('- Calendário: Lembretes e datas importantes.', style: TextStyle(fontSize: 16)),
            const Text('- Perfil: Dados do casal, personalização e configurações.', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),

            // Tecnologias
            const Text(
              '🚀 Tecnologias Utilizadas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('- Flutter (Dart)', style: TextStyle(fontSize: 16)),
            const Text('- Provider para gerenciamento de estado', style: TextStyle(fontSize: 16)),
            const Text('- Table Calendar para calendário customizado', style: TextStyle(fontSize: 16)),
            const Text('- Intl para datas em português', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),

            // Diferenciais
            const Text(
              '💡 Diferenciais',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('- Foco em fortalecer o vínculo do casal', style: TextStyle(fontSize: 16)),
            const Text('- Incentivo a atividades offline e pausas digitais', style: TextStyle(fontSize: 16)),
            const Text('- Interface simples, leve e intuitiva', style: TextStyle(fontSize: 16)),
            const Text('- Personalização de temas e informações', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),

            // Equipe
            const Text(
              '👥 Equipe',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Somos uma equipe de 10 pessoas apaixonadas por tecnologia e bem-estar digital.', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),

            const Text(
              'Liderança:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const Text('- Front-end: Samuel Ramos', style: TextStyle(fontSize: 16)),
            const Text('- Back-end: Maria Vitória', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),

            const Text(
              'Equipe:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const Text('- Jailson', style: TextStyle(fontSize: 16)),
            const Text('- Gabriel', style: TextStyle(fontSize: 16)),
            const Text('- Joan', style: TextStyle(fontSize: 16)),
            const Text('- Thiago', style: TextStyle(fontSize: 16)),
            const Text('- Mariana', style: TextStyle(fontSize: 16)),
            const Text('- Gabrielly', style: TextStyle(fontSize: 16)),
            const Text('- Fábio', style: TextStyle(fontSize: 16)),
            const Text('- Juan', style: TextStyle(fontSize: 16)),
            const Text('- Ian', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final String text;
  final String description;

  const FeatureItem({
    super.key,
    required this.text,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          children: [
            TextSpan(
              text: '• $text\n',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: description,
            ),
          ],
        ),
      ),
    );
  }
}
