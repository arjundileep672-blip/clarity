import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../viewmodels/socratic_buddy_viewmodel.dart';

class SocraticBuddyView extends StatelessWidget {
  const SocraticBuddyView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SocraticBuddyViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ask Without Fear'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
            iconSize: 28,
            tooltip: 'Go back',
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.spa_rounded),
              onPressed: () => _showBreakDialog(context),
              tooltip: 'Take a Break',
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              color: AppColors.primaryLight,
              child: Row(
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Text(
                      'There are no dumb questions here.',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Expanded(child: _ChatMessageList()),

            const _ChatInputBar(),
          ],
        ),
      ),
    );
  }

  static void _showBreakDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        ),
        title: Row(
          children: [
            Icon(Icons.spa_rounded, color: AppColors.accent),
            const SizedBox(width: AppSpacing.s),
            Text('Take a Break', style: AppTextStyles.title),
          ],
        ),
        content: Text(
          'It\'s okay to step away and come back when you\'re ready. Your progress is saved.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Continue Learning'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}

class _ChatMessageList extends StatefulWidget {
  const _ChatMessageList();

  @override
  State<_ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<_ChatMessageList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = context.watch<SocraticBuddyViewModel>().messages;

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppSpacing.m),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return _MessageBubble(message: messages[index]);
      },
    );
  }
}

class _ChatInputBar extends StatefulWidget {
  const _ChatInputBar();

  @override
  State<_ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<_ChatInputBar> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final viewModel = context.read<SocraticBuddyViewModel>();
    if (_messageController.text.trim().isNotEmpty) {
      viewModel.sendMessage(_messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.overlay,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.mic_none_rounded),
              onPressed: null,
              iconSize: 28,
              tooltip: 'Voice input (coming soon)',
              color: AppColors.textTertiary,
            ),

            const SizedBox(width: AppSpacing.s),

            Expanded(
              child: TextField(
                controller: _messageController,
                maxLines: null,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  hintText: 'Ask your question…',
                  hintStyle: AppTextStyles.body.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.m,
                    vertical: AppSpacing.s,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),

            const SizedBox(width: AppSpacing.s),

            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded),
                onPressed: _sendMessage,
                color: Colors.white,
                tooltip: 'Send message',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Row(
        mainAxisAlignment: message.isStudent
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isStudent) ...[
            CircleAvatar(
              backgroundColor: AppColors.accent,
              radius: 20,
              child: Icon(
                Icons.psychology_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.s),
          ],

          Flexible(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: message.isStudent
                    ? AppColors.primary
                    : AppColors.accentLight,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppSpacing.radiusMedium),
                  topRight: const Radius.circular(AppSpacing.radiusMedium),
                  bottomLeft: Radius.circular(
                    message.isStudent
                        ? AppSpacing.radiusMedium
                        : AppSpacing.radiusSmall,
                  ),
                  bottomRight: Radius.circular(
                    message.isStudent
                        ? AppSpacing.radiusSmall
                        : AppSpacing.radiusMedium,
                  ),
                ),
              ),
              child: Text(
                message.text,
                style: AppTextStyles.body.copyWith(
                  color: message.isStudent
                      ? Colors.white
                      : AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ),

          if (message.isStudent) ...[
            const SizedBox(width: AppSpacing.s),
            CircleAvatar(
              backgroundColor: AppColors.primaryDark,
              radius: 20,
              child: Icon(Icons.person_rounded, color: Colors.white, size: 20),
            ),
          ],
        ],
      ),
    );
  }
}
