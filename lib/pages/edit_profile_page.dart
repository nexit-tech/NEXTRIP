import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import '../components/custom_button.dart';
import '../components/custom_input.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> currentProfile;

  const EditProfilePage({super.key, required this.currentProfile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _supabase = Supabase.instance.client;
  late TextEditingController _nameController;
  bool _isLoading = false;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentProfile['full_name']);
    _avatarUrl = widget.currentProfile['avatar_url'];
  }

  // --- UPLOAD DE FOTO (CORRIGIDO PARA WEB E MOBILE) ---
  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    // Permite escolher da galeria
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // Otimiza o tamanho da imagem
    );

    if (image == null) return;

    setState(() => _isLoading = true);

    try {
      // 1. Ler os bytes (Dados brutos) da imagem - Funciona na Web e Mobile
      final bytes = await image.readAsBytes();
      
      final fileExt = image.path.split('.').last;
      final fileName = '${_supabase.auth.currentUser!.id}-${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // 2. Upload Binary (Essencial para Web)
      await _supabase.storage.from('profile-avatars').uploadBinary(
        fileName,
        bytes,
        fileOptions: FileOptions(
          cacheControl: '3600', 
          upsert: false,
          contentType: image.mimeType ?? 'image/$fileExt', // Importante para o navegador saber que é imagem
        ),
      );

      // 3. Pegar URL Pública
      final imageUrl = _supabase.storage.from('profile-avatars').getPublicUrl(fileName);

      // 4. Atualizar Tabela Profiles
      await _supabase.from('profiles').update({
        'avatar_url': imageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', _supabase.auth.currentUser!.id);

      setState(() {
        _avatarUrl = imageUrl;
      });
      
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Foto atualizada!")));

    } catch (e) {
      debugPrint("Erro upload: $e");
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro no upload: $e"), backgroundColor: Colors.red));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  // --- ATUALIZAR NOME ---
  Future<void> _updateName() async {
    setState(() => _isLoading = true);
    try {
      await _supabase.from('profiles').update({
        'full_name': _nameController.text,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', _supabase.auth.currentUser!.id);

      if(mounted) {
        Navigator.pop(context, true); // Retorna true para recarregar a tela anterior
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Perfil atualizado!")));
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao atualizar."), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- ALTERAR SENHA ---
  Future<void> _resetPassword() async {
    try {
      final email = _supabase.auth.currentUser?.email;
      if (email != null) {
        await _supabase.auth.resetPasswordForEmail(email);
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email de redefinição enviado!")));
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao enviar email."), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: const Text("Dados da Conta", style: TextStyle(color: AppColors.white)),
        backgroundColor: AppColors.black,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Foto de Perfil com Botão de Editar
            GestureDetector(
              onTap: _pickAndUploadImage,
              child: Stack(
                children: [
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                      image: _avatarUrl != null 
                        ? DecorationImage(image: NetworkImage(_avatarUrl!), fit: BoxFit.cover)
                        : null,
                    ),
                    child: _avatarUrl == null 
                      ? const Icon(Icons.person, size: 50, color: AppColors.chineseWhite) 
                      : null,
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, size: 16, color: AppColors.black),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Align(alignment: Alignment.centerLeft, child: Text("Nome Completo", style: TextStyle(color: AppColors.chineseWhite, fontSize: 12))),
            const SizedBox(height: 8),
            CustomInput(controller: _nameController, hint: "Seu Nome", icon: Icons.person),

            const SizedBox(height: 16),
            // Email (Read Only)
            const Align(alignment: Alignment.centerLeft, child: Text("Email (Não alterável)", style: TextStyle(color: AppColors.chineseWhite, fontSize: 12))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.eerieBlack.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.nightRider),
              ),
              child: Text(widget.currentProfile['email'] ?? '', style: const TextStyle(color: Colors.grey)),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'SALVAR ALTERAÇÕES', 
                isLoading: _isLoading,
                onPressed: _updateName,
              ),
            ),

            const SizedBox(height: 24),
            const Divider(color: AppColors.nightRider),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'ALTERAR SENHA',
                isOutlined: true,
                icon: Icons.lock_reset,
                onPressed: _resetPassword,
              ),
            ),
          ],
        ),
      ),
    );
  }
}