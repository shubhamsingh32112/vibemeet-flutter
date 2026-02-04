Installation
Choosing The Right Flutter Package

Why the SDK is split into different packages
Different applications need different levels of customization and integration with the Stream Chat SDK. To do this, the Flutter SDK is split into three different packages which build upon the last and give varying levels of control to the developer. The higher level packages offer better compatibility out of the box while the lower level SDKs offer fine grained control. There is also a separate package for persistence which allows you persist data locally which works with all packages.

How do I choose?
The case for stream_chat_flutter
For the quickest way to integrate Stream Chat with your app, the UI SDK (stream_chat_flutter) is the way to go. stream_chat_flutter contains prebuilt components that manage most operations like data fetching, pagination, sending a message, and more. This ensures you have a nearly out-of-the-box experience adding chat to your applications. It is also possible to use this in conjunction with lower level operations of the SDK to get the best of both worlds.

The package allows customization of components to a large extent making it easy to tweak the theme to match your app colors and such. If you require any additional feature or customization, feel free to request this through our support channels.

Summary:

For the quickest and easiest way to add Chat to your app with prebuilt UI components, use stream_chat_flutter

The case for stream_chat_flutter_core
If your application involves UI that does not fit in with the stream_chat_flutter components, stream_chat_flutter_core strips away the UI associated with the components and provides the data fetching and manipulation capabilities while supplying builders for UI. This allows you to implement your own UI and themes completely independently while not worrying about writing functions for data and pagination.

Summary:

For implementing your own custom UI while not having to worry about lower level API calls, use stream_chat_flutter_core.

The case for stream_chat
The stream_chat package is the Low-level Client (LLC) of Stream Chat in Flutter. This package wraps the underlying functionality of Stream Chat and allows the most customization in terms of UI, data, and architecture.

Summary:

For the most control over the SDK and dealing with low level calls to the API, use stream_chat.


Getting Started
Understanding The UI Package Of The Flutter SDK

What function does stream_chat_flutter serve?
The UI SDK (stream_chat_flutter) contains official Flutter components for Stream Chat, a service for building chat applications.

While the Stream Chat service functions as the messaging backend and the LLC offers a straightforward integration for Flutter apps, our goal was to ensure the quick incorporation of Chat functionality into your application. To further simplify this process, we developed a dedicated UI package.

The UI package is built on top of the low-level client and the core package and allows you to build a full fledged app with either the inbuilt components, modify existing components, or easily add widgets of your own to match your app's style better.

Add pub.dev dependency
First, you need to add the stream_chat_flutter dependency to your pubspec.yaml.

You can either run this command:


flutter pub add stream_chat_flutter
OR

Add this line in the dependencies section of your pubspec.yaml after substituting the latest version:


dependencies:
  stream_chat_flutter: ^latest_version
You can find the package details on pub.dev.

Details On Platform Support
As of the latest version, thestream_chat_flutter package (UI) added support for web, macOS, Windows, and Linux - on top of the original support for Android and iOS. It has, however, been possible to target desktop and web since Flutter added support for these platforms using the stream_chat_flutter_core (builder) and stream_chat (low-level client) packages - this remains unchanged.

Please note that Flutter Web may have additional constraints due to not supporting all plugins that Stream Chat relies on. The respective plugin creators will address this over time.

Setup
This section provides setup instructions for the respective platforms.

Android
The package uses photo_manager to access the device's photo library. Follow this wiki to fulfill the Android requirements.

iOS
The library uses flutter file picker plugin to pick files from the os. Follow this wiki to fulfill iOS requirements.

Stream Chat also uses the video_player package to play videos. Follow this guide to fulfill the requirements.

Stream Chat uses the image_picker plugin. Follow these instructions to check the requirements.

Web
For the web, edit your index.html and add the following in the <body> tag to allow the SDK to override the right-click behavior:


<body oncontextmenu="return false;"></body>
macOS
For macOS Stream Chat uses the file_selector package. Follow these instructions to check the requirements.

You also need to add the following entitlements to Release.entitlement and DebugProfile.entitlement:


<key>com.apple.security.network.client</key>
<true/>
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
Which grants:

Internet permission
File access permission

Theming
Understanding How To Customize Widgets Using StreamChatTheme

Find the pub.dev documentation here and here

Background
Stream's UI SDK makes it easy for developers to add custom styles and attributes to our widgets. Like most Flutter frameworks, Stream exposes a dedicated widget for theming.

Using StreamChatTheme, users can customize most aspects of our UI widgets by setting attributes using StreamChatThemeData.

Similar to the Theme and ThemeData in Flutter, Stream Chat uses a top level inherited widget to provide theming information throughout your application. This can be optionally set at the top of your application tree or at a localized point in your widget sub-tree.

If you'd like to customize the look and feel of Stream chat across your entire application, we recommend setting your theme at the top level. Conversely, users can customize specific screens or widgets by wrapping components in a StreamChatTheme.

A closer look at StreamChatThemeData
Looking at the constructor for StreamChatThemeData, we can see the full list of properties and widgets available for customization.

Some high-level properties such as textTheme or colorTheme can be set application-wide directly from this class. In contrast, larger components such as ChannelHeader, MessageInputs, etc. have been broken up into smaller theme objects.


factory StreamChatThemeData({
    Brightness? brightness,
    TextTheme? textTheme,
    ColorTheme? colorTheme,
    StreamChannelListHeaderThemeData? channelListHeaderTheme,
    StreamChannelPreviewThemeData? channelPreviewTheme,
    StreamChannelHeaderThemeData? channelHeaderTheme,
    StreamMessageThemeData? otherMessageTheme,
    StreamMessageThemeData? ownMessageTheme,
    StreamMessageInputThemeData? messageInputTheme,
    Widget Function(BuildContext, User)? defaultUserImage,
    PlaceholderUserImage? placeholderUserImage,
    IconThemeData? primaryIconTheme,
    List<StreamReactionIcon>? reactionIcons,
    StreamGalleryHeaderThemeData? imageHeaderTheme,
    StreamGalleryFooterThemeData? imageFooterTheme,
    StreamMessageListViewThemeData? messageListViewTheme,
  });
Stream Chat Theme in use
Let's take a look at customizing widgets using StreamChatThemeData. In the example below, we can change the default color theme to yellow and override the channel header's typography and colors.


MaterialApp(
  builder: (context, child) => StreamChat(
    client: client,
    streamChatThemeData: StreamChatThemeData(
      colorTheme: StreamColorTheme.light(
        accentPrimary: const Color(0xffffe072),
      ),
        channelHeaderTheme: const ChannelHeaderThemeData(
          color: const Color(0xffd34646),
          titleStyle: TextStyle(
            color: Colors.white,
          ),
        ),
    ),
    child: child,
  ),
);
We are creating this class at the very top of our widget tree using the streamChatThemeData parameter found in the StreamChat widget.


StreamChannelHeader
A Widget To Display Common Channel Details

Find the pub.dev documentation here


Background
When a user opens a channel, it is helpful to provide context of which channel they are in. This may be in the form of a channel name or the users in the channel. Along with that, there also needs to be a way for the user to look at more details of the channel (media, pinned messages, actions, etc.) and preferably also a way to navigate back to where they came from.

To encapsulate all of this functionality into one widget, the Flutter SDK contains a StreamChannelHeader widget which provides these out of the box.

Basic Example
Let's just add a StreamChannelHeader to a page with a StreamMessageListView and a StreamMessageInput to display and send messages.


class ChannelPage extends StatelessWidget {
  const ChannelPage({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StreamChannelHeader(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamMessageListView(
              threadBuilder: (_, parentMessage) {
                return ThreadPage(
                  parent: parentMessage,
                );
              },
            ),
          ),
          const StreamMessageInput(),
        ],
      ),
    );
  }
}
Customizing Parts Of The Header
The header works like a ListTile widget.

Use the title, subtitle, leading, or actions parameters to substitute the widgets for your own.


//...
StreamChannelHeader(
    title: Text('My Custom Name'),
),

Showing Connection State
The StreamChannelHeader can also display connection state below the tile which shows the user if they are connected or offline, etc. on connection events.

To enable this, use the showConnectionStateTile property.


//...
StreamChannelHeader(
    showConnectionStateTile: true,
),

StreamMessageListView
A Widget For Displaying A List Of Messages

Find the pub.dev documentation here


Background
Every channel can contain a list of messages sent by users inside it. The StreamMessageListView widget displays the list of messages inside a particular channel along with possible attachments and other message attributes (if the message is pinned for example). This sets it apart from the StreamMessageSearchListView which may not contain messages only from a single channel and is used to search for messages across many.

Basic Example
The StreamMessageListView shows the list of messages of the current channel. It has inbuilt support for common messaging functionality: displaying and editing messages, adding / modifying reactions, support for quoting messages, pinning messages, and more.

An example of how you can use the StreamMessageListView is:


class ChannelPage extends StatelessWidget {
  const ChannelPage({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StreamChannelHeader(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamMessageListView(),
          ),
          const StreamMessageInput(),
        ],
      ),
    );
  }
}
Enable Threads
Threads are made of a parent message and replies linked to it. To enable threading, the SDK requires you to supply a threadBuilder which will supply the page when the thread is clicked.


StreamMessageListView(
    threadBuilder: (_, parentMessage) {
        return ThreadPage(
            parent: parentMessage,
        );
    },
),

The StreamMessageListView itself can render the thread by supplying the parentMessage parameter.


StreamMessageListView(
    parentMessage: parent,
),
Building Custom Messages
You can also supply your own implementation for displaying messages using the messageBuilder parameter.

To customize the existing implementation, look at the StreamMessageWidget documentation instead.


StreamMessageListView(
    messageBuilder: (context, details, messageList, defaultImpl) {
        // Your implementation of the message here
        // E.g: return Text(details.message.text ?? '');
    },
),


Message List View
Customizing Text Messages

Introduction
Every application provides a unique look and feel to their own messaging interface including and not limited to fonts, colors, and shapes.

This guide details how to customize message text in the StreamMessageListView / StreamMessageWidget in the Stream Chat Flutter UI SDK.

This guide is specifically for the StreamMessageListView but if you intend to display a StreamMessageWidget separately, follow the same process without the .copyWith and use the default constructor instead.

Basics of customizing a StreamMessageWidget
First, add a StreamMessageListView in the appropriate place where you intend to display messages from a channel.


StreamMessageListView(
    ...
)
Now, we use the messageBuilder parameter to build a custom message. The builder function also provides the default implementation of the StreamMessageWidget so that we can change certain aspects of the widget without redoing all of the default parameters.

In earlier versions of the SDK, some StreamMessageWidget parameters were exposed directly through the StreamMessageListView, however, this quickly becomes hard to maintain as more parameters and customizations are added to the StreamMessageWidget. Newer version utilise a cleaner interface to change the parameters by supplying a default message implementation as aforementioned.


StreamMessageListView(
    ...
    messageBuilder: (context, messageDetails, messageList, defaultWidget) {
        return defaultWidget;
    },
)
We use .copyWith() to customize the widget:


StreamMessageListView(
    ...
    messageBuilder: (context, messageDetails, messageList, defaultWidget) {
        return defaultWidget.copyWith(
            ...
        );
    },
)
Customizing text
If you intend to simply change the theme for the text, you need not recreate the whole widget. The StreamMessageWidget has a messageTheme parameter that allows you to pass the theme for most aspects of the message.


StreamMessageListView(
    ...
    messageBuilder: (context, messageDetails, messageList, defaultWidget) {
        return defaultWidget.copyWith(
            messageTheme: StreamMessageThemeData(
                ...
                messageTextStyle: TextStyle(),
            ),
        );
    },
)
If you want to replace the entire text widget in the StreamMessageWidget, you can use the textBuilder parameter which provides a builder for creating a widget to substitute the default text.parameter


StreamMessageListView(
    ...
    messageBuilder: (context, messageDetails, messageList, defaultWidget) {
        return defaultWidget.copyWith(
            textBuilder: (context, message) {
                return Text(message.text ?? '');
            },
        );
    },
)
Adding Hashtags
To add elements like hashtags, we can override the textBuilder in the StreamMessageWidget:


StreamMessageListView(
    ...
    messageBuilder: (context, messageDetails, messageList, defaultWidget) {
        return defaultWidget.copyWith(
            textBuilder: (context, message) {
                final text = _replaceHashtags(message.text)?.replaceAll('\n', '\\\n');
                final messageTheme = StreamChatTheme.of(context).ownMessageTheme;
                if (text == null) return const SizedBox();
                return MarkdownBody(
                    data: text,
                    onTapLink: (
                        String link,
                        String? href,
                        String title,
                        ) {
                      // Do something with tapped hashtag
                    },
                    styleSheet: MarkdownStyleSheet.fromTheme(
                      Theme.of(context).copyWith(
                        textTheme: Theme.of(context).textTheme.apply(
                          bodyColor: messageTheme.messageTextStyle?.color,
                          decoration: messageTheme.messageTextStyle?.decoration,
                          decorationColor: messageTheme.messageTextStyle?.decorationColor,
                          decorationStyle: messageTheme.messageTextStyle?.decorationStyle,
                          fontFamily: messageTheme.messageTextStyle?.fontFamily,
                        ),
                      ),
                    ).copyWith(
                      a: messageTheme.messageLinksStyle,
                      p: messageTheme.messageTextStyle,
                    ),
                );
            },
        );
    },
)
String? _replaceHashtags(String? text) {
  if (text == null) return null;
  final exp = RegExp(r"\B#\w\w+");
  String result = text;
  exp.allMatches(text).forEach((match){
    text = text!.replaceAll(
        '${match.group(0)}', '[${match.group(0)}](/chat/docs/sdk/flutter/stream_chat_flutter/custom_widgets/customize_text_messages/${match.group(0/)?.replaceAll(' ', '')})');
  });
  return result;
}
We can replace the hashtags using RegEx and add links for the MarkdownBody which is done here in the _replaceHashtags() function. Inside the textBuilder, we use the flutter_markdown package to build our hashtags as links.


StreamMessageWidget
A Widget For Displaying Messages And Attachments

Find the pub.dev documentation here

Background
There are several things that need to be displayed with text in a message in a modern messaging app: attachments, highlights if the message is pinned, user avatars of the sender, etc.

To encapsulate all of this functionality into one widget, the Flutter SDK contains a StreamMessageWidget widget which provides these out of the box.

Basic Example (Modifying StreamMessageWidget in StreamMessageListView)
Primarily, the StreamMessageWidget is used in the StreamMessageListView. To customize only a few properties of the StreamMessageWidget without supplying all other properties, the messageBuilder builder supplies a default implementation of the widget for us to modify.


class ChannelPage extends StatelessWidget {
  const ChannelPage({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamMessageListView(
        messageBuilder: (context, details, messageList, defaultMessageWidget) {
           return defaultMessageWidget.copyWith(
             showThreadReplyIndicator: false,
           );
        },
      ),
    );
  }
}
Building A Custom Attachment
When a custom attachment type (location, audio, etc.) is sent, the MessageWidget also needs to know how to build it. For this purpose, we can use the customAttachmentBuilders parameter.

As an example, if a message has a attachment type 'location', we do:


StreamMessageWidget(
    //...
    customAttachmentBuilders: {
        'location': (context, message, attachments) {
            var attachmentWidget = Image.network(
              _buildMapAttachment(
                attachments[0].extraData['latitude'],
                attachments[0].extraData['longitude'],
              ),
            );
        return WrapAttachmentWidget(
              attachmentWidget: attachmentWidget,
              attachmentShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            );
    }
  },
)
You can also override the builder for existing attachment types like image and video.

Show User Avatar For Messages
You can decide to show, hide, or remove user avatars of the sender of the message. To do this, set the showUserAvatar property like this:


StreamMessageWidget(
    //...
    showUserAvatar: DisplayWidget.show,
)
Reverse the message
In most cases, StreamMessageWidget needs to be a different orientation depending upon if the sender is the user or someone else.

For this, we use the reverse parameter to change the orientation of the message:


StreamMessageWidget(
    //...
    reverse: true,
)


StreamMessageSearchListView
A Widget To Search For Messages Across Channels

Find the pub.dev documentation here


Background
Users in Stream Chat can have several channels and it can get hard to remember which channel has the message they are searching for. As such, there needs to be a way to search for a message across multiple channels. This is where StreamMessageSearchListView comes in.

Make sure to check the StreamMessageSearchListController documentation for more information on how to use the controller to manipulate the StreamMessageSearchListView.

Basic Example
While the StreamMessageListView is tied to a certain StreamChannel, a StreamMessageSearchListView is not.


class StreamMessageSearchPage extends StatefulWidget {
  const StreamMessageSearchPage({
    super.key,
    required this.client,
  });
  final StreamChatClient client;
  @override
  State<StreamMessageSearchPage> createState() => _StreamMessageSearchState();
}
class _StreamMessageSearchState extends State<StreamMessageSearchPage> {
  late final _controller = StreamMessageSearchListController(
    client: widget.client,
    limit: 20,
    filter: Filter.in_(
      'members',
      [StreamChat.of(context).user!.id],
    ),
    searchQuery: 'your query here',
  );
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => Scaffold(
        body: StreamMessageSearchListView(
          controller: _controller,
        ),
      );
}
Customize The Result Tiles
You can use your own widget for the result items using the itemBuilder parameter.


StreamMessageSearchListView(
  // ...
  itemBuilder: (context, responses, index, defaultWidget) {
    return Text(responses[index].message.text);
  },
),


StreamMessageSearchGridView
A Widget To Search For Messages Across Channels

Find the pub.dev documentation here

Background
The StreamMessageSearchGridView widget allows displaying a list of searched messages in a GridView.

Make sure to check the StreamMessageSearchListView documentation to know how to show results in a ListView.

Basic Example

class StreamMessageSearchPage extends StatefulWidget {
  const StreamMessageSearchPage({
    super.key,
    required this.client,
  });
  final StreamChatClient client;
  @override
  State<StreamMessageSearchPage> createState() => _StreamMessageSearchState();
}
class _StreamMessageSearchState extends State<StreamMessageSearchPage> {
  late final _controller = StreamMessageSearchListController(
    client: widget.client,
    limit: 20,
    filter: Filter.in_(
      'members',
      [StreamChat.of(context).user!.id],
    ),
    searchQuery: 'your query here',
  );
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => Scaffold(
        body: StreamMessageSearchGridView(
          controller: _controller,
          itemBuilder: (context, values, index) {
           // return your custom widget here
          },
        ),
      );
}


Message
Customizing Text Messages with the StreamMessageWidget

Introduction
Every application provides a unique look and feel to their own messaging interface including and not limited to fonts, colors, and shapes.

This guide details how to customize the StreamMessageWidget in the Stream Chat Flutter UI SDK.

Building Custom Messages
This guide goes into detail about the ability to customize the StreamMessageWidget. However, if you want to customize the default StreamMessageWidget in the StreamMessageListView provided, you can use the .copyWith() method provided inside the messageBuilder parameter of the StreamMessageListView like this:


StreamMessageListView(
    messageBuilder: (context, details, messageList, defaultImpl) {
        return defaultImpl.copyWith(
            ...
        );
    },
),
Providing Custom Reaction Icons
By default the StreamReactionIcon widgets provided by the SDK are love, like, sad, haha, and wow. However, you can provide your own custom reaction icons by providing a reactionIcons parameter to the StreamChatConfigurationData.


StreamChat(
  client: client,
  streamChatConfigData: StreamChatConfigurationData(
    reactionIcons: [
      StreamReactionIcon(
        type: 'custom',
        builder: (context, isHighlighted, iconSize) {
          return Icon(
            Icons.star,
            size: iconSize,
            color: isHighlighted ? Colors.red : Colors.black,
          );
        },
      ),
    ]
  ),
  child: //Your widget here
)
Theming
You can customize the StreamMessageWidget using the StreamChatTheme class, so that you can change the message theme at the top instead of creating your own StreamMessageWidget at the lower implementation level.

There are several things you can change in the theme including text styles and colors of various elements.

You can also set a different theme for the user's own messages and messages received by them.

Theming allows you to change minor factors like style while using the widget directly allows you much more customization such as replacing a certain widget with another. Some things can only be customized through the widget and not the theme.

Here is an example:


StreamChatThemeData(
  /// Sets theme for user's messages
  ownMessageTheme: StreamMessageThemeData(
    messageBackgroundColor: colorTheme.textHighEmphasis,
  ),
  /// Sets theme for received messages
  otherMessageTheme: StreamMessageThemeData(
    avatarTheme: StreamAvatarThemeData(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
)

Change message text style
The StreamMessageWidget has multiple Text widgets that you can manipulate the styles of. The three main are the actual message text, user name, message links, and the message timestamp.


StreamMessageThemeData(
  messageTextStyle: TextStyle(...),
  createdAtStyle: TextStyle(...),
  messageAuthorStyle: TextStyle(...),
  messageLinksStyle: TextStyle(...),
)

Change avatar theme
You can change the attributes of the avatar (if displayed) using the avatarTheme property.


StreamMessageThemeData(
    avatarTheme: StreamAvatarThemeData(
      borderRadius: BorderRadius.circular(8),
    ),
)

Changing Reaction theme
You also customize the reactions attached to every message using the theme.


StreamMessageThemeData(
  reactionsBackgroundColor: Colors.red,
  reactionsBorderColor: Colors.redAccent,
  reactionsMaskColor: Colors.pink,
),

Changing Message Actions
When a message is long pressed, the StreamMessageActionsModal is shown.

The StreamMessageWidget allows showing or hiding some options if you so choose.


StreamMessageWidget(
    ...
    showUsername = true,
    showTimestamp = true,
    showReactions = true,
    showDeleteMessage = true,
    showEditMessage = true,
    showReplyMessage = true,
    showThreadReplyMessage = true,
    showResendMessage = true,
    showCopyMessage = true,
    showFlagButton = true,
    showPinButton = true,
    showPinHighlight = true,
),

Building attachments
The attachmentBuilders property allows you to build any kind of attachment (inbuilt or custom) in your own way. While a separate guide is written for this, it is included here because of relevance.


class LocationAttachmentBuilder extends StreamAttachmentWidgetBuilder {
  @override
  bool canHandle(
    Message message,
    Map<String, List<Attachment>> attachments,
  ) {
    final imageAttachments = attachments['location'];
    return imageAttachments != null && imageAttachments.length == 1;
  }
  @override
  Widget build(
    BuildContext context,
    Message message,
    Map<String, List<Attachment>> attachments,
  ) {
    final attachmentWidget = Image.network(
      _buildMapAttachment(
        attachments[0].extraData['latitude'],
        attachments[0].extraData['longitude'],
      ),
    );
    return WrapAttachmentWidget(
      attachmentWidget: attachmentWidget,
      attachmentShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
StreamMessageListView(
  messageBuilder: (context, details, messages, defaultMessage) {
    return defaultMessage.copyWith(
        attachmentBuilders: const [
            LocationAttachmentBuilder(),
        ],
    );
  },
),
Widget Builders
Some parameters allow you to construct your own widget in place of some elements in the StreamMessageWidget.

These are:

userAvatarBuilder : Allows user to substitute their own widget in place of the user avatar.
editMessageInputBuilder : Allows user to substitute their own widget in place of the input in edit mode.
textBuilder : Allows user to substitute their own widget in place of the text.
bottomRowBuilder : Allows user to substitute their own widget in the bottom of the message when not deleted.
deletedBottomRowBuilder : Allows user to substitute their own widget in the bottom of the message when deleted.

StreamMessageWidget(
    ...
    textBuilder: (context, message) {
        // Add your own text implementation here.
    },
),


StreamMessageInput
A Widget Dealing With Everything Related To Sending A Message

Find the pub.dev documentation here


Background
In Stream Chat, we can send messages in a channel. However, sending a message isn't as simple as adding a TextField and logic for sending a message. It involves additional processes like addition of media, quoting a message, adding a custom command like a GIF board, and much more. Moreover, most apps also need to customize the input to match their theme, overall color and structure pattern, etc.

To do this, we created a StreamMessageInput widget which abstracts all expected functionality a modern input needs - and allows you to use it out of the box.

Basic Example
A StreamChannel is required above the widget tree in which the StreamMessageInput is rendered since the channel is where the messages sent actually go. Let's look at a common example of how we could use the StreamMessageInput:


class ChannelPage extends StatelessWidget {
  const ChannelPage({
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StreaChannelHeader(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamMessageListView(
              threadBuilder: (_, parentMessage) {
                return ThreadPage(
                  parent: parentMessage,
                );
              },
            ),
          ),
          StreamMessageInput(),
        ],
      ),
    );
  }
}
It is common to put this widget in the same page of a StreamMessageListView as the bottom widget.

Make sure to check the StreamMessageInputController documentation for more information on how to use the controller to manipulate the StreamMessageInput.

Adding Custom Actions
By default, the StreamMessageInput has two actions: one for attachments and one for commands like Giphy. To add your own action, we use the actions parameter like this:


StreamMessageInput(
  actions: [
    InkWell(
      child: Icon(
        Icons.location_on,
        size: 20,
        color: StreamChatTheme.of(context).colorTheme.textLowEmphasis,
      ),
      onTap: () {
        // Do something here
      },
    ),
  ],
),
This will add on your action to the existing ones.

Disable Attachments
To disable attachments being added to the message, set the disableAttachments parameter to true.


StreamMessageInput(
    disableAttachments: true,
),
Changing Position Of MessageInput Components
You can also change the position of the TextField, actions and 'send' button relative to each other.

To do this, use the actionsLocation or sendButtonLocation parameters which help you decide the location of the buttons in the input.

For example, if we want the actions on the right and the send button inside the TextField, we can do:


StreamMessageInput(
    sendButtonLocation: SendButtonLocation.inside,
    actionsLocation: ActionsLocation.right,
),


Message Actions
Customizing Message Actions

Introduction
Message actions pop up in message overlay, when you long-press a message.


We have provided granular control over these actions.

By default we render the following message actions:

edit message

delete message

reply

thread reply

copy message

flag message

pin message

mark unread

Edit and delete message are only available on messages sent by the user. Additionally, pinning a message requires you to add the roles which are allowed to pin messages.

Mark unread message is only available on messages sent by other users and only when read events are enabled for the channel. Additionally, it's not possible to mark messages inside threads as unread.

Partially remove some message actions
For example, if you only want to keep "copy message" and "delete message": here is how to do it using the messageBuilder with our StreamMessageWidget.


StreamMessageListView(
  messageBuilder: (context, details, messages, defaultMessage) {
    return defaultMessage.copyWith(
        showFlagButton: false,
        showEditMessage: false,
        showCopyMessage: true,
        showDeleteMessage: details.isMyMessage,
        showReplyMessage: false,
        showThreadReplyMessage: false,
        showMarkUnreadMessage: false,
    );
  },
)
Add a new custom message action
The SDK also allows you to add new actions into the dialog.

For example, let's suppose you want to introduce a new message action - "Demo Action":

We use the customActions parameter of the StreamMessageWidget to add extra actions.


StreamMessageListView(
  messageBuilder: (context, details, messages, defaultMessage) {
    return defaultMessage.copyWith(
      customActions: [
        StreamMessageAction(
          leading: const Icon(Icons.add),
          title: const Text('Demo Action'),
          onTap: (message) {
            /// Complete action here
          },
        ),
      ],
    );
  },
)

StreamChannelListView
A Widget For Displaying A List Of Channels

Find the pub.dev documentation here


Background
Channels are fundamental elements of Stream Chat and constitute shared spaces which allow users to message each other.

1:1 conversations and groups are both examples of channels, albeit with some (distinct/non-distinct) differences. Displaying the list of channels that a user is a part of is a pattern present in most messaging apps.

The StreamChannelListView widget allows displaying a list of channels to a user. By default, this is NOT ONLY the channels that the user is a part of. This section goes into setting up and using a StreamChannelListView widget.

Make sure to check the StreamChannelListController documentation for more information on how to use the controller to manipulate the StreamChannelListView.

Basic Example
Here is a basic example of the StreamChannelListView widget. It consists of the main widget itself, a StreamChannelListController to control the list of channels and a callback to handle the tap of a channel.


class ChannelListPage extends StatefulWidget {
  const ChannelListPage({
    super.key,
    required this.client,
  });
  final StreamChatClient client;
  @override
  State<ChannelListPage> createState() => _ChannelListPageState();
}
class _ChannelListPageState extends State<ChannelListPage> {
  late final _controller = StreamChannelListController(
    client: widget.client,
    filter: Filter.in_(
      'members',
      [StreamChat.of(context).currentUser!.id],
    ),
    channelStateSort: const [SortOption('last_message_at')],
  );
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => Scaffold(
        body: RefreshIndicator(
          onRefresh: _controller.refresh,
          child: StreamChannelListView(
            controller: _controller,
            onChannelTap: (channel) => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StreamChannel(
                  channel: channel,
                  child: const ChannelPage(),
                ),
              ),
            ),
          ),
        ),
      );
}
This example by default displays the channels that a user is a part of. Now let's look at customizing the widget.

Customizing the Channel Preview
A common aspect of the widget needed to be tweaked according to each app is the Channel Preview (the Channel tile in the list). To do this, we use the itemBuilder parameter like this:


StreamChannelListView(
  ...
  itemBuilder: (context, channels, index, defaultTile) {
    return ListTile(
      tileColor: Colors.amberAccent,
      title: Center(
        child: StreamChannelName(channel: channels[index]),
      ),
    );
  },
),
Which gives you a new Channel preview in the list:



StreamChannelListHeader
A Header Widget For A List Of Channels

Find the pub.dev documentation here


Background
A common pattern for most messaging apps is to show a list of Channels (chats) on the first screen and navigate to an individual one on being clicked. On this first page where the list of channels are displayed, it is usual to have functionality such as adding a new chat, display the user logged in, etc.

To encapsulate all of this functionality into one widget, the Flutter SDK contains a StreamChannelListHeader widget which provides these out of the box.

Basic Example
This is a basic example of a page which has a StreamChannelListView and a StreamChannelListHeader to recreate a common Channels Page.


class ChannelListPage extends StatefulWidget {
  const ChannelListPage({
    super.key,
    required this.client,
  });
  final StreamChatClient client;
  @override
  State<ChannelListPage> createState() => _ChannelListPageState();
}
class _ChannelListPageState extends State<ChannelListPage> {
  late final _controller = StreamChannelListController(
    client: widget.client,
    filter: Filter.in_(
      'members',
      [StreamChat.of(context).currentUser!.id],
    ),
    channelStateSort: const [SortOption('last_message_at')],
  );
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const StreamChannelListHeader(),
        body: RefreshIndicator(
          onRefresh: _controller.refresh,
          child: StreamChannelListView(
            controller: _controller,
            onChannelTap: (channel) => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StreamChannel(
                  channel: channel,
                  child: const ChannelPage(),
                ),
              ),
            ),
          ),
        ),
      );
}
Customizing Parts Of The Header
The header works like a ListTile widget.

Use the titleBuilder, subtitle, leading, or actions parameters to substitute the widgets for your own.


//...
StreamChannelListHeader(
    subtitle: Text('My Custom Subtitle'),
),

The titleBuilder parameter helps you build different titles depending on the connection state:


//...
StreamChannelListHeader(
    titleBuilder: (context, status, client) {
        switch(status) {
            /// Return your title widget
        }
    },
),
Showing Connection State
The StreamChannelListHeader can also display connection state below the tile which shows the user if they are connected or offline, etc. on connection events.

To enable this, use the showConnectionStateTile property.


//...
StreamChannelListHeader(
    showConnectionStateTile: true,
),
Did you find this page helpful?

StreamChannelGridView
A Widget For Displaying A List Of Channels

Find the pub.dev documentation here

Background
The StreamChannelGridView widget allows displaying a list of channels to a user in a GridView.

Make sure to check the StreamChannelListView documentation to know how to show results in a ListView.

Basic Example
Here is a basic example of the StreamChannelGridView widget. It consists of the main widget itself, a StreamChannelListController to control the list of channels and a callback to handle the tap of a channel.


class ChannelGridPage extends StatefulWidget {
  const ChannelGridPage({
    Key? key,
    required this.client,
  }) : super(key: key);
  final StreamChatClient client;
  @override
  State<ChannelGridPage> createState() => _ChannelGridPageState();
}
class _ChannelGridPageState extends State<ChannelGridPage> {
  late final _controller = StreamChannelListController(
    client: widget.client,
    filter: Filter.in_(
      'members',
      [StreamChat.of(context).currentUser!.id],
    ),
    channelStateSort: const [SortOption('last_message_at')],
  );
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => Scaffold(
        body: RefreshIndicator(
          onRefresh: _controller.refresh,
          child: StreamChannelGridView(
            controller: _controller,
            onChannelTap: (channel) => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StreamChannel(
                  channel: channel,
                  child: const ChannelPage(),
                ),
              ),
            ),
          ),
        ),
      );
}
This example by default displays the channels that a user is a part of. Now let's look at customizing the widget.


Channel List Preview
Slidable Channel List Preview

Introduction
The default slidable behavior within the channel list has been removed in v4 of the Stream Chat Flutter SDK. This guide will show you how you can easily add this functionality yourself.

Please see our full v4 migration guide if you're migrating from an earlier version of the Stream Chat Flutter SDK.

Slidable demo
Prerequisites
This guide assumes you are familiar with the Stream Chat SDK. If you're new to Stream Chat Flutter, we recommend looking at our getting started tutorial.

Dependencies:


dependencies:
  flutter:
    sdk: flutter
  stream_chat_flutter: ^6.0.0
  flutter_slidable: ^3.0.0
⚠️ Note: The examples shown in this guide use the above packages and versions.

Example Code - Custom Stream Channel Item Builder
In this example, you are doing a few important things in the ChannelListPage widget. You're:

Using the flutter_slidable package to easily add slide functionality.
Passing in the itemBuilder argument for the StreamChannelListView widget. This gives access to the current BuildContext, Channel, and StreamChannelListTile, and allows you to create, or customize, the stream channel list tiles.
Returning a Slidable widget with two CustomSlidableAction widgets - to delete a channel and show more options. These widgets come from the flutter_slidable package.
Adding onPressed behaviour to call showConfirmationBottomSheet and showChannelInfoModalBottomSheet. These methods come from the stream_chat_flutter package. They have a few different on-tap callbacks you can supply, for example, onViewInfoTap. Alternatively, you can create custom dialog screens from scratch.
Using the StreamChannelListController to perform actions, such as, deleteChannel.

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
void main() async {
  final client = StreamChatClient(
    's2dxdhpxd94g',
  );
  await client.connectUser(
    User(id: 'super-band-9'),
    '''eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoic3VwZXItYmFuZC05In0.0L6lGoeLwkz0aZRUcpZKsvaXtNEDHBcezVTZ0oPq40A''',
  );
  runApp(
    MyApp(
      client: client,
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
    required this.client,
  }) : super(key: key);
  final StreamChatClient client;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => StreamChat(
        client: client,
        child: child,
      ),
      home: ChannelListPage(
        client: client,
      ),
    );
  }
}
class ChannelListPage extends StatefulWidget {
  const ChannelListPage({
    Key? key,
    required this.client,
  }) : super(key: key);
  final StreamChatClient client;
  @override
  State<ChannelListPage> createState() => _ChannelListPageState();
}
class _ChannelListPageState extends State<ChannelListPage> {
  late final _controller = StreamChannelListController(
    client: widget.client,
    filter: Filter.in_(
      'members',
      [StreamChat.of(context).currentUser!.id],
    ),
    channelStateSort: const [SortOption('last_message_at')],
  );
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SlidableAutoCloseBehavior(
          child: RefreshIndicator(
            onRefresh: _controller.refresh,
            child: StreamChannelListView(
              controller: _controller,
              itemBuilder: (context, channels, index, tile) {
                final channel = channels[index];
                final chatTheme = StreamChatTheme.of(context);
                final backgroundColor = chatTheme.colorTheme.inputBg;
                final canDeleteChannel = channel.ownCapabilities
                    .contains(PermissionType.deleteChannel);
                return Slidable(
                  groupTag: 'channels-actions',
                  endActionPane: ActionPane(
                    extentRatio: canDeleteChannel ? 0.40 : 0.20,
                    motion: const BehindMotion(),
                    children: [
                      CustomSlidableAction(
                        onPressed: (_) {
                          showChannelInfoModalBottomSheet(
                            context: context,
                            channel: channel,
                            onViewInfoTap: () {
                              Navigator.pop(context);
                              // Navigate to info screen
                            },
                          );
                        },
                        backgroundColor: backgroundColor,
                        child: const Icon(Icons.more_horiz),
                      ),
                      if (canDeleteChannel)
                        CustomSlidableAction(
                          backgroundColor: backgroundColor,
                          child: StreamSvgIcon.delete(
                            color: chatTheme.colorTheme.accentError,
                          ),
                          onPressed: (_) async {
                            final res = await showConfirmationBottomSheet(
                              context,
                              title: 'Delete Conversation',
                              question:
                                  'Are you sure you want to delete this conversation?',
                              okText: 'Delete',
                              cancelText: 'Cancel',
                              icon: StreamSvgIcon.delete(
                                color: chatTheme.colorTheme.accentError,
                              ),
                            );
                            if (res == true) {
                              await _controller.deleteChannel(channel);
                            }
                          },
                        ),
                    ],
                  ),
                  child: tile,
                );
              },
              onChannelTap: (channel) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StreamChannel(
                    channel: channel,
                    child: const ChannelPage(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
class ChannelPage extends StatelessWidget {
  const ChannelPage({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const StreamChannelHeader(),
        body: Column(
          children: const <Widget>[
            Expanded(
              child: StreamMessageListView(),
            ),
            StreamMessageInput(),
          ],
        ),
      );
}
The above is the complete sample, and all you need for a basic implementation.


StreamThreadListView
StreamThreadListView is a widget that shows an overview of all threads of which the user is a member. It shows information about the channel, the thread parent message, the most recent reply in the thread, and the number of unread replies.

The list is paginated by default, and only the most recently updated threads are loaded initially. Older threads are loaded only when the user scrolls to the end of the thread list.

The StreamThreadListView widget is available on the Flutter SDK since version 9.1.0

Usage
The widget is backed by a controller named StreamThreadListController, which is responsible for loading the threads and managing the state of the widget.


late final _threadListController = StreamThreadListController(
  limit: 30,
  client: StreamChat.of(context).client,
  options: ThreadOptions(
    replyLimit: ...,
    memberLimit: ...,
    participantLimit: ...,
  ),
);
The StreamThreadListController has a few properties that can be used to customize the behavior of the widget:

limit: The maximum number of threads to load per page.
ThreadOptions.replyLimit: The maximum number of (latest) replies to load per thread.
ThreadOptions.memberLimit: The maximum number of members to load per thread.
ThreadOptions.participantLimit: The maximum number of participants to load per thread.
Once the controller is created, it can be passed to the StreamThreadListView widget.


StreamThreadListView(
  controller: _threadListController,
);
This will create a paginated list of threads, which will load more threads as the user scrolls to the end of the list.

No threads	Thread list
Empty
Loaded
Unread Threads
While the user is viewing the thread list, and a new thread is created, or a thread which is not yet loaded is updated, we can show a banner informing the user about the number of new threads. The user can then click on the banner to reload the thread list and load the newly updated threads.

To implement this feature, we can use the StreamUnreadThreadsBanner widget and pass the number of unread threads to it.


Column(
  children: [
    ValueListenableBuilder(
      valueListenable: _threadListController.unseenThreadIds,
      builder: (_, unreadThreads, __) => StreamUnreadThreadsBanner(
        unreadThreads: unreadThreads,
        onTap: () => _threadListController
            .refresh(resetValue: false)
            // Clear the list of unseen threads once the threads are refreshed.
            .then((_) => controller.clearUnseenThreadIds()),
      ),
    ),
    Expanded(
      child: StreamThreadListView(
        controller: _threadListController,
      ),
    ),
  ],
);
This will show a banner at the top of the thread list, which will display the number of unread threads. When the user clicks on the banner, the thread list will be refreshed, and the banner will be hidden.

Unread Threads
Handling Thread Taps
To handle taps on threads, we can use the onThreadTap callback provided by the StreamThreadListView widget.


StreamThreadListView(
  controller: _threadListController,
  onThreadTap: (thread) {
    // Handle the tap on the thread.
  },
);
We can also handle long presses on threads using the onThreadLongPress callback.


StreamThreadListView(
  controller: _threadListController,
  onThreadLongPress: (thread) {
    // Handle the long press on the thread.
  },
);
Customizing Thread Items
You can customize the appearance of the thread items using the itemBuilder parameter.


StreamThreadListView(
  controller: _threadListController,
  itemBuilder: (context, threads, index, defaultWidget) {
    final thread = threads[index];
    // Return your custom widget here.
  },
);
Custom Thread ListTile
Other Customizations
The StreamThreadListView widget provides a few other parameters that can be used to customize the appearance and behavior of the widget:


StreamThreadListView(
  controller: controller,
  emptyBuilder: (context) {
    // Return your custom empty state widget here.
  },
  loadingBuilder: (context) {
    // Return your custom loading state widget here.
  },
  errorBuilder: (context, error) {
    // Return your custom error state widget here.
  },
  separatorBuilder: (context, threads, index) {
    // Return your custom separator widget here.
  },
);


Voice Recording
Stream Chat's Flutter SDK allows you to record and share async voice messages in your channels. The voice recordings have a built-in attachment type (as defined here).

Voice Recordings on Flutter SDK are available since version 9.3.0

Voice recording is disabled by default. In order to enable it, you should setup the enableVoiceRecording property to true in the MessageInput widget


StreamMessageInput(
  ...
  enableVoiceRecording: true,
)
As soon as you do that, an additional "Voice Recording" icon button would be shown in the Message Input.

Voice Recording Enabled
Recording UI Flows
The voice recording feature supports several different UI flows.

Idle
The default state of the voice recording button is the idle state where the user can hold on the button to start recording.

Voice Recording Idle
Additionally, if the user lifts the finger before the recording starts, a tooltip is shown to inform the user to hold the button to start recording.

Voice Recording Idle Tooltip
Hold Recording
When the user long presses on the voice recording button longer than 1 second, the recording is started. In that case, while the button is still pressed, the recording view is shown.

The recording view provides the following actions:

add the recording to the message input (invoked when releasing the long press button)
slide to cancel (invoked when you drag to the slide to cancel indicator)
lock the recording (invoked when drag towards the lock button)
Voice Recording Hold Recording
Locked Recording
When the user drags the recording view towards the lock button, the recording is locked. In that case, the recording no longer requires the user to hold the button to keep recording.

The locked recording view provides the following actions:

stop the recording (invoked when the stop button is pressed)
finish the recording (invoked when the finish button is pressed)
cancel the recording (invoked when the cancel button is pressed)
Additionally, the locked recording view shows the recording duration and the recording waveform.

Voice Recording Locked Recording
Stopped Recording
When the user stops the recording, the recording can be played back, or the user can choose to cancel or finish the recording.

The stopped recording view provides the following actions:

play the recording (invoked when the play button is pressed)
pause the recording (invoked when the pause button is pressed)
seek the recording (invoked when the user drags the seek bar)
finish the recording (invoked when the finish button is pressed)
cancel the recording (invoked when the cancel button is pressed)
Additionally, the stopped recording view shows the recording duration and the recording waveform.

Voice Recording Stopped
Finished Recording
When the user finishes the recording, the recording is added to the message input. The user can choose to play the recording, remove the recording, or send the recording.

Additionally, the user can also add more recordings to the message input by holding the voice recording button again.

Note: If you wish to send the recording automatically after the recording is finished, you can set the sendVoiceRecordingAutomatically property to true in the StreamMessageInput widget.


StreamMessageInput(
  ...
  sendVoiceRecordingAutomatically: true,
)
Voice Recording Finished
Voice Recording Attachment
Once the recording is sent, the recording is added to the message list view as an attachment.

Voice Recording Attachment
Customizing Voice Recording
The voice recording UI can be customized using the StreamVoiceRecordingAttachmentTheme.


StreamVoiceRecordingAttachmentTheme(
  data: StreamVoiceRecordingAttachmentThemeData(
    backgroundColor: const Color(0xffDCF7C5),
    playIcon: const Icon(Icons.play_arrow_rounded),
    pauseIcon: const Icon(Icons.pause_rounded),
    titleTextStyle: const TextStyle(color: Colors.black54),
    durationTextStyle: const TextStyle(color: Colors.black54),
    audioControlButtonStyle: ElevatedButton.styleFrom(
      elevation: 2,
      iconColor: Colors.white,
      minimumSize: const Size(36, 36),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      backgroundColor: Colors.black54,
      shape: const CircleBorder(),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    speedControlButtonStyle: ElevatedButton.styleFrom(
      elevation: 2,
      minimumSize: const Size(40, 28),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      backgroundColor: Colors.black54,
      shape: const StadiumBorder(),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    audioWaveformSliderTheme: const StreamAudioWaveformSliderThemeData(
      audioWaveformTheme: StreamAudioWaveformThemeData(
        color: Colors.black54,
        progressColor: Colors.black,
      ),
      thumbColor: Colors.black,
      thumbBorderColor: Colors.black,
    ),
  ),
  child: ...
);
This will customize the voice recording attachment UI with the specified theme.

Voice Recording Attachment Custom

Introduction
Understanding The Core Package Of The Flutter SDK

This package provides business logic to fetch common things required for integrating Stream Chat into your application. The core package allows more customisation and hence provides business logic but no UI components. Please use the stream_chat_flutter package for the full fledged suite of UI components or stream_chat for the low-level client.

Background
In the early days of the Flutter SDK, the SDK was only split into the LLC (stream_chat) and the UI package (stream_chat_flutter). With this you could use a fully built interface with the UI package or a fully custom interface with the LLC. However, we soon recognised the need for a third intermediary package which made tasks like building and modifying a list of channels or messages easy but without the complexity of using low level components. The Core package (stream_chat_flutter_core) is a manifestation of the same idea and allows you to build an interface with Stream Chat without having to deal with low level code and architecture as well as implementing your own theme and UI effortlessly. Also, it has very few dependencies.

We will now explore the components of this intermediary package and understand how it helps you build the experience you want your users to have.

The package primarily contains a bunch of controller classes. Controllers are used to handle the business logic of the chat. You can use them together with our UI widgets, or you can even use them to build your own UI.

StreamChannelListController
StreamUserListController
StreamMessageSearchListController
StreamMessageInputController
LazyLoadScrollView
PagedValueListenableBuilder
This section goes into the individual core package widgets and their functional use.


Setup
Understanding Setup For stream_chat_flutter_core

Add pub.dev dependency
First, you need to add the stream_chat_flutter_core dependency to your pubspec.yaml

You can either run this command:


flutter pub add stream_chat_flutter_core
OR

Add this line in the dependencies section of your pubspec.yaml after substituting latest version:


dependencies:
  stream_chat_flutter_core: ^latest_version
You can find the package details on pub.dev.


Chat Client
StreamChatCore is a version of StreamChat found in stream_chat_flutter that is decoupled from theme and initialisations.

Find the pub.dev documentation here

StreamChatCore is used to provide information about the chat client to the widget tree. This Widget is used to react to life cycle changes and system updates. When the app goes into the background, the web socket connection is automatically closed and when it goes back to foreground the connection is opened again.

Like the StreamChat widget in the higher level UI package, the StreamChatCore widget should be on the top level before using any Stream functionality:


return MaterialApp(
      title: 'Stream Chat Core Example',
      home: HomeScreen(),
      builder: (context, child) => StreamChatCore(
        client: client,
        child: child,
      ),
    );


Offline Support
Adding Local Data Persistence for Offline Support

Introduction
Most messaging apps need to work regardless of whether the app is currently connected to the internet. Local data persistence stores the fetched data from the backend on a local SQLite database using the drift package in Flutter. All packages in the SDK can use local data persistence to store messages across multiple platforms.

Implementation
To add data persistence you can extend the class ChatPersistenceClient and pass an instance to the StreamChatClient.


class CustomChatPersistentClient extends ChatPersistenceClient {
...
}
final client = StreamChatClient(
  apiKey ?? kDefaultStreamApiKey,
  logLevel: Level.INFO,
)..chatPersistenceClient = CustomChatPersistentClient();
We provide an official persistent client in the stream_chat_persistence package that works using the library drift, an SQLite ORM.

Add this to your package's pubspec.yaml file, using the latest version.


dependencies:
  stream_chat_persistence: ^latest_version
You should then run flutter packages get

The usage is pretty simple.

Create a new instance of StreamChatPersistenceClient providing logLevel and connectionMode

final chatPersistentClient = StreamChatPersistenceClient(
  logLevel: Level.INFO,
  connectionMode: ConnectionMode.background,
);
Pass the instance to the official StreamChatClient

final client = StreamChatClient(
    apiKey ?? kDefaultStreamApiKey,
    logLevel: Level.INFO,
  )..chatPersistenceClient = chatPersistentClient;
And you are ready to go...

Note that passing ConnectionMode.background the database uses a background isolate to unblock the main thread. The StreamChatClient uses the chatPersistentClient to synchronize the database with the newest information every time it receives new data about channels/messages/users.

Multi-user
The DB file is named after the userId, so if you instantiate a client using a different userId you will use a different database. Calling client.disconnectUser(flushChatPersistence: true) flushes all current database data.

Updating/deleting/sending a message while offline
The information about the action is saved in offline storage. When the client returns online, everything is retried.


Channel State & Filtering
A Widget For Controlling A List Of Channels

Find the pub.dev documentation here

Background
The StreamChannelListController is a controller class that allows you to control a list of channels. StreamChannelListController is a required parameter of the StreamChannelListView widget. Check the StreamChannelListView documentation to read more about that.

The StreamChannelListController also listens for various events and manipulates the current list of channels accordingly. Passing a StreamChannelListEventHandler to the StreamChannelListController will allow you to customize this behaviour.

Basic Example
Building a custom channel list is a very common task. Here is an example of how to use the StreamChannelListController to build a simple list with pagination.

First of all we should create an instance of the StreamChannelListController and provide it with the StreamChatClient instance. You can also add a Filter, a list of SortOptions and other pagination-related parameters.


class _MyChannelListPageState extends State<MyChannelListPage> {
  /// Controller used for loading more data and controlling pagination in
  /// [StreamChannelListController].
  late final channelListController = StreamChannelListController(
    client: StreamChatCore.of(context).client,
    filter: Filter.and([
      Filter.equal('type', 'messaging'),
      Filter.in_(
        'members',
        [
          StreamChatCore.of(context).currentUser!.id,
        ],
      ),
    ]),
  );
  ...
}
Make sure you call channelListController.doInitialLoad() to load the initial data and channelListController.dispose() when the controller is no longer required.


@override
void initState() {
  channelListController.doInitialLoad();
  super.initState();
}
@override
void dispose() {
  channelListController.dispose();
  super.dispose();
}
The StreamChannelListController is basically a PagedValueNotifier that notifies you when the list of channels has changed. You can use a PagedValueListenableBuilder to build your UI depending on the latest channels.


@override
Widget build(BuildContext context) => Scaffold(
      body: PagedValueListenableBuilder<int, Channel>(
        valueListenable: channelListController,
        builder: (context, value, child) {
          return value.when(
            (channels, nextPageKey, error) => LazyLoadScrollView(
              onEndOfPage: () async {
                if (nextPageKey != null) {
                  channelListController.loadMore(nextPageKey);
                }
              },
              child: ListView.builder(
                /// We're using the channels length when there are no more
                /// pages to load and there are no errors with pagination.
                /// In case we need to show a loading indicator or and error
                /// tile we're increasing the count by 1.
                itemCount: (nextPageKey != null || error != null)
                    ? channels.length + 1
                    : channels.length,
                itemBuilder: (BuildContext context, int index) {
                  if (index == channels.length) {
                    if (error != null) {
                      return TextButton(
                          onPressed: () {
                            channelListController.retry();
                          },
                          child: Text(error.message),
                        );
                    }
                    return const CircularProgressIndicator();
                  }
                  final _item = channels[index];
                  return ListTile(
                    title: Text(_item.name ?? ''),
                    subtitle: StreamBuilder<Message?>(
                      stream: _item.state!.lastMessageStream,
                      initialData: _item.state!.lastMessage,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(snapshot.data!.text!);
                        }
                        return const SizedBox();
                      },
                    ),
                    onTap: () {
                      /// Display a list of messages when the user taps on
                      /// an item. We can use [StreamChannel] to wrap our
                      /// [MessageScreen] screen with the selected channel.
                      ///
                      /// This allows us to use a built-in inherited widget
                      /// for accessing our `channel` later on.
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => StreamChannel(
                            channel: _item,
                            child: const MessageScreen(),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            loading: () => const Center(
              child: SizedBox(
                height: 100,
                width: 100,
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e) => Center(
              child: Text(
                'Oh no, something went wrong. '
                'Please check your config. $e',
              ),
            ),
          );
        },
      ),
    );
In this case we're using the LazyLoadScrollView widget to load more data when the user scrolls to the bottom of the list.


Channels Events
A Class To Customize The Event Handler For The StreamChannelListController.

Find the pub.dev documentation here

Background
A StreamChannelListEventHandler is a class that handles the events that are related to the channel list loaded by StreamChannelListController. The StreamChannelListController automatically creates a StreamChannelListEventHandler internally and handles the events. In order to provide a custom implementation of StreamChannelListEventHandler, you need to create a class that extends the StreamChannelListEventHandler class.

Basic Example
There are 2 ways to provide a custom implementation of StreamChannelListEventHandler:

Create a class that extends the StreamChannelListEventHandler and pass it down to the controller.

class MyCustomEventHandler extends StreamChannelListEventHandler {
  @override
  void onConnectionRecovered(
    Event event,
    StreamChannelListController controller,
  ) {
    // Write your own custom implementation here
  }
}
Pass it down to the controller:


late final listController = StreamChannelListController(
    client: StreamChat.of(context).client,
    eventHandler: MyCustomEventHandler(),
  );
Mix the StreamChannelListEventHandler into your widget state.

class _ChannelListPageState extends State<ChannelListPage> {
  late final _listController = StreamChannelListController(
    client: StreamChat.of(context).client,
    eventHandler: MyCustomEventHandler(),
  );
}


Messages State
A Widget For Building A List Of Messages

Find the pub.dev documentation here

Background
The UI SDK of Stream Chat supplies a MessageListView class that builds a list of channels fetching according to the filters and sort order given. However, in some cases, implementing novel UI is necessary that cannot be done using the customization approaches given in the widget.

To do this, we extracted the logic required for fetching channels into a 'Core' widget - a widget that fetches channels in the expected way via the usual parameters but does not supply any UI and instead exposes builders to build the UI in situations such as loading, empty data, errors, and on data received.

Basic Example
MessageListCore is a simplified class that allows fetching a list of messages while exposing UI builders.

This allows you to construct your own UI while not having to worry about the specific logic of fetching messages in a channel.

A MessageListController is used to paginate data.


class ChannelPage extends StatelessWidget {
  const ChannelPage({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: MessageListCore(
        emptyBuilder: (context) {
          return const Center(
            child: Text('Nothing here...'),
          );
        },
        loadingBuilder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        messageListBuilder: (context, list) {
          return MessagesPage(list);
        },
        errorBuilder: (context, err) {
          return const Center(
            child: Text('Error'),
          );
        },
            ),
          ),
        ],
      ),
    );
  }
}
Make sure to have a StreamChannel ancestor in order to provide the information about the channels.


Message Composer State
A Widget For Controlling A Message Input

Find the pub.dev documentation here

Background
The StreamMessageInputController is a controller class that embed the business logic to compose a message. StreamMessageInputController is a parameter of the StreamMessageInput widget. Check the StreamMessageInput documentation to read more about that.

Basic Example
Building a custom message input is a common task. Here is an example of how to use the StreamMessageInputController to build a simple custom message input widget.

First of all we should create an instance of the StreamMessageInputController.


class MessageScreenState extends State<MessageScreen> {
  final StreamMessageInputController messageInputController = StreamMessageInputController();
Make sure you call messageInputController.dispose() when the controller is no longer required.


@override
void dispose() {
  messageInputController.dispose();
  super.dispose();
}
The StreamMessageInputController is basically a ValueNotifier that notifies you when the message being composed has changed. You can use a ValueListenableBuilder to build your UI depending on the latest message. For a very simple message input you could even pass the messageInputController.textEditingController to your TextField and set the onChanged callback.


...
Padding(
  padding: const EdgeInsets.all(8),
  child: Row(
    children: [
      Expanded(
        child: TextField(
          controller: messageInputController.textFieldController,
          onChanged: (s) => messageInputController.text = s,
          decoration: const InputDecoration(
            hintText: 'Enter your message',
          ),
        ),
      ),
      Material(
        type: MaterialType.circle,
        color: Colors.blue,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () async {
            if (messageInputController.message.text?.isNotEmpty ==
                true) {
              await channel.sendMessage(
                messageInputController.message,
              );
              messageInputController.clear();
              if (context.mounted) {
                _updateList();
              }
            }
          },
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Center(
              child: Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    ],
  ),
),
...


Message Search State
A Widget For Controlling A List Of Searched Messages

Find the pub.dev documentation here

Background
The StreamMessageSearchListController is a controller class that allows you to control a list of searched messages. StreamMessageSearchListController is a required parameter of the StreamMessageSearchListView widget. Check the StreamMessageSearchListView documentation to read more about that.

Basic Example
Building a custom message search feature is a common task. Here is an example of how to use the StreamMessageSearchListController to build a simple search list with pagination.

First of all we should create an instance of the StreamMessageSearchListController and provide it with the StreamChatClient instance. We can then add a filter to only get the channels that the current user is a part of. You can also add a list of SortOptions and other pagination-related parameters.


class SearchListPageState extends State<SearchListPage> {
  /// Controller used for loading more data and controlling pagination in
  /// [StreamMessageSearchListController].
  late final messageSearchListController = StreamMessageSearchListController(
    client: StreamChatCore.of(context).client,
    filter: Filter.in_('members', [StreamChat.of(context).currentUser!.id]),
  );
Make sure you call messageSearchListController.doInitialLoad() to load the initial data and messageSearchListController.dispose() when the controller is no longer required.


@override
void initState() {
  messageSearchListController.doInitialLoad();
  super.initState();
}
@override
void dispose() {
  messageSearchListController.dispose();
  super.dispose();
}
The StreamMessageSearchListController is basically a PagedValueNotifier that notifies you when the list of responses has changed. You can use a PagedValueListenableBuilder to build your UI depending on the latest responses.


@override
Widget build(BuildContext context) => Scaffold(
      body: Column(
        children: [
          TextField(
            /// This is just a sample implementation of a search field.
            /// In a real-world app you should throttle the search requests.
            /// You can use our library [rate_limiter](https://pub.dev/packages/rate_limiter).
            onChanged: (s) {
              messageSearchListController..searchQuery = s..doInitialLoad();
            },
          ),
          Expanded(
            child: PagedValueListenableBuilder<String, GetMessageResponse>(
              valueListenable: messageSearchListController,
              builder: (context, value, child) {
                return value.when(
                  (responses, nextPageKey, error) => LazyLoadScrollView(
                    onEndOfPage: () async {
                      if (nextPageKey != null) {
                        messageSearchListController.loadMore(nextPageKey);
                      }
                    },
                    child: ListView.builder(
                      /// We're using the responses length when there are no more
                      /// pages to load and there are no errors with pagination.
                      /// In case we need to show a loading indicator or and error
                      /// tile we're increasing the count by 1.
                      itemCount: (nextPageKey != null || error != null)
                          ? responses.length + 1
                          : responses.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == responses.length) {
                          if (error != null) {
                            return TextButton(
                              onPressed: () {
                                messageSearchListController.retry();
                              },
                              child: Text(error.message),
                            );
                          }
                          return const CircularProgressIndicator();
                        }
                        final _item = responses[index];
                        return ListTile(
                          title: Text(_item.channel?.name ?? ''),
                          subtitle: Text(_item.message.text ?? ''),
                        );
                      },
                    ),
                  ),
                  loading: () => const Center(
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e) => Center(
                    child: Text(
                      'Oh no, something went wrong. '
                      'Please check your config. $e',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
In this case we're using the LazyLoadScrollView widget to load more data when the user scrolls to the bottom of the list.


Members State
A widget for controlling a list of members.

Find the pub.dev documentation here

Background
The StreamMemberListController is a controller class that allows you to control a list of users. StreamMemberListController is a required parameter of the StreamMemberListView widget. Check the StreamMemberListView documentation to read more about that.

Basic Example
Building a custom member list is a very common task. Here is an example of how to use the StreamMemberListController to build a simple list with pagination.

First, create an instance of the StreamMemberListController and provide it with the StreamChatClient instance. You can also add a Filter, a list of SortOptions, and other pagination-related parameters.


class MemberListPageState extends State<MemberListPage> {
  /// Controller used for loading more data and controlling pagination in
  /// [StreamMemberListController].
  late final memberListController = StreamMemberListController(
    channel: StreamChannel.of(context).channel,
  );
Make sure you call memberListController.doInitialLoad() to load the initial data and memberListController.dispose() when the controller is no longer required.


@override
void initState() {
  memberListController.doInitialLoad();
  super.initState();
}
@override
void dispose() {
  memberListController.dispose();
  super.dispose();
}
The StreamMemberListController is basically a PagedValueNotifier that notifies you when the list of members has changed. You can use a PagedValueListenableBuilder to build your UI depending on the latest members.


@override
Widget build(BuildContext context) => Scaffold(
      body: PagedValueListenableBuilder<int, Member>(
        valueListenable: memberListController,
        builder: (context, value, child) {
          return value.when(
            (members, nextPageKey, error) => LazyLoadScrollView(
              onEndOfPage: () async {
                if (nextPageKey != null) {
                  memberListController.loadMore(nextPageKey);
                }
              },
              child: ListView.builder(
                /// We're using the members length when there are no more
                /// pages to load and there are no errors with pagination.
                /// In case we need to show a loading indicator or and error
                /// tile we're increasing the count by 1.
                itemCount: (nextPageKey != null || error != null)
                    ? members.length + 1
                    : members.length,
                itemBuilder: (BuildContext context, int index) {
                  if (index == members.length) {
                    if (error != null) {
                      return TextButton(
                          onPressed: () {
                            memberListController.retry();
                          },
                          child: Text(error.message),
                        );
                    }
                    return const CircularProgressIndicator();
                  }
                  final _item = members[index];
                  return ListTile(
                    title: Text(_item.user?.name ?? ''),
                  );
                },
              ),
            ),
            loading: () => const Center(
              child: SizedBox(
                height: 100,
                width: 100,
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e) => Center(
              child: Text(
                'Oh no, something went wrong. '
                'Please check your config. $e',
              ),
            ),
          );
        },
      ),
    );
In this case, we're using the LazyLoadScrollView widget to load more data when the user scrolls to the bottom of the list.


Users State & Filtering
A Widget For Controlling A List Of Users

Find the pub.dev documentation here

Background
The StreamUserListController is a controller class that allows you to control a list of users. StreamUserListController is a required parameter of the StreamUserListView widget. Check the StreamUserListView documentation to read more about that.

Basic Example
Building a custom user list is a very common task. Here is an example of how to use the StreamUserListController to build a simple list with pagination.

First of all we should create an instance of the StreamUserListController and provide it with the StreamChatClient instance. You can also add a Filter, a list of SortOptions and other pagination-related parameters.


class UserListPageState extends State<UserListPage> {
  /// Controller used for loading more data and controlling pagination in
  /// [StreamUserListController].
  late final userListController = StreamUserListController(
    client: StreamChatCore.of(context).client,
  );
Make sure you call userListController.doInitialLoad() to load the initial data and userListController.dispose() when the controller is no longer required.


@override
void initState() {
  userListController.doInitialLoad();
  super.initState();
}
@override
void dispose() {
  userListController.dispose();
  super.dispose();
}
The StreamUserListController is basically a PagedValueNotifier that notifies you when the list of users has changed. You can use a PagedValueListenableBuilder to build your UI depending on the latest users.


@override
Widget build(BuildContext context) => Scaffold(
      body: PagedValueListenableBuilder<int, User>(
        valueListenable: userListController,
        builder: (context, value, child) {
          return value.when(
            (users, nextPageKey, error) => LazyLoadScrollView(
              onEndOfPage: () async {
                if (nextPageKey != null) {
                  userListController.loadMore(nextPageKey);
                }
              },
              child: ListView.builder(
                /// We're using the users length when there are no more
                /// pages to load and there are no errors with pagination.
                /// In case we need to show a loading indicator or and error
                /// tile we're increasing the count by 1.
                itemCount: (nextPageKey != null || error != null)
                    ? users.length + 1
                    : users.length,
                itemBuilder: (BuildContext context, int index) {
                  if (index == users.length) {
                    if (error != null) {
                      return TextButton(
                          onPressed: () {
                            userListController.retry();
                          },
                          child: Text(error.message),
                        );
                    }
                    return const CircularProgressIndicator();
                  }
                  final _item = users[index];
                  return ListTile(
                    title: Text(_item.name),
                  );
                },
              ),
            ),
            loading: () => const Center(
              child: SizedBox(
                height: 100,
                width: 100,
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e) => Center(
              child: Text(
                'Oh no, something went wrong. '
                'Please check your config. $e',
              ),
            ),
          );
        },
      ),
    );
In this case we're using the LazyLoadScrollView widget to load more data when the user scrolls to the bottom of the list.



Paging
A Widget For Building A Paginated List

Find the pub.dev documentation here

Background
The LazyLoadScrollView is a widget that helps you build a paginated list. It provides callbacks to notify you when the list has been scrolled to the bottom and when the list has been scrolled to the top and other necessary callbacks.

Callbacks
onStartOfPage: called when the list has been scrolled to the top of the page.

onEndOfPage: called when the list has been scrolled to the bottom of the page.

onPageScrollStart: called when the scroll of the list starts.

onPageScrollEnd: called when the scroll of the list ends.

onInBetweenOfPage: called when the list is not either at the top nor at the bottom of the page.

Basic Example
Building a paginated list is a very common task. Here is an example of how to use the LazyLoadScrollView to build a simple list with pagination.


LazyLoadScrollView(
  onEndOfPage: _paginateData,
  /// The child could be any widget which dispatches [ScrollNotification]s.
  /// For example [ListView], [GridView] or [CustomScrollView].
  child: ListView.builder(
    itemBuilder: (context, index) => _buildListTile,
  ),
)



Synchronize Paging Data
A Widget Whose Content Stays Synced With A ValueNotifier Of Type PagedValue.

Find the pub.dev documentation here

Background
Given a PagedValueNotifier<Key, Value> implementation and a [builder] which builds widgets from concrete values of PagedValue<Key, Value>, this class will automatically register itself as a listener of the [PagedValueNotifier] and call the [builder] with updated values when the value changes.

Basic Example

class UserNameValueNotifier extends PagedValueNotifier<int, String> {
  UserNameValueNotifier() : super(const PagedValue.loading());
  @override
  Future<void> doInitialLoad() async {
    // Imitating network delay
    await Future.delayed(const Duration(seconds: 1));
    value = const PagedValue(
      items: ['Sahil', 'Salvatore', 'Reuben'],
      /// Passing the key to load the next page
      nextPageKey: nextPageKey,
    );
  }
  @override
  Future<void> loadMore(int nextPageKey) async {
    // Imitating network delay
    await Future.delayed(const Duration(seconds: 1));
    final previousItems = value.asSuccess.items;
    final newItems = previousItems + ['Deven', 'Sacha', 'Gordon'];
    value = PagedValue(
      items: newItems,
      // Passing nextPageKey as null to indicate
      // that there are no more items.
      nextPageKey: null,
    );
  }
}
class _MyHomePageState extends State {
  final pagedValueNotifier = UserNameValueNotifier();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: PagedValueListenableBuilder<int, String>(
          builder: (context, value, child) {
            // This builder will only get called when the _counter
            // is updated.
            return value.when(
              (userNames, nextPageKey, error) => Column(
                children: [
                  const Text('Usernames:'),
                  Expanded(
                    child: ListView(
                      children: userNames.map(Text.new).toList(),
                    ),
                  ),
                  if (nextPageKey != null)
                    TextButton(
                      child: const Text('Load more'),
                      onPressed: () => pagedValueNotifier.loadMore(nextPageKey),
                    ),
                ],
              ),
              loading: CircularProgressIndicator.new,
              error: (e) => Text('Error: $e'),
            );
          },
          valueListenable: pagedValueNotifier,
        ),
      ),
    );
  }
}


Push Notifications
Adding Push Notifications (V2) To Your Application

Introduction
This guide details how to add push notifications to your app.

Push notifications are a core part of the experience for a messaging app. Users often need to be notified of new messages and old notifications sometimes need to be updated silently.

Stream Chat sends push notification to channel members that have at least one registered device. Push notifications are only sent for new messages and not for other events. You can use Webhooks to send push notifications on other types of events.

You can read more about Stream’s push delivery logic.

To receive push notifications from Stream Chat, you'll need to:

Configure your push notification provider on the Stream Dashboard.
Add the client-side integration. For Flutter this guide demonstrates using Firebase Cloud Messaging (FCM).
Push Delivery Rules
Push message delivery behaves according to these rules:

Push notifications are sent only for new messages.
Only channel members receive push messages.
Members receive push notifications regardless of their online status.
Replies inside a thread are only sent to users that are part of that thread:
They posted at least one message
They were mentioned
Messages from muted users are not sent.
Messages from muted channels are not sent.
Messages are sent to all registered devices for a user (up to 25).
The message doesn't contain the flag skip_push as true.
push_notifications is enabled (default) on the channel type for message is sent.
Push notifications require membership. Watching a channel isn't enough.

Setup FCM
To integrate push notifications in your Flutter app, you need to use the package firebase_messaging.

Follow the Flutter Firebase documentation to set up the plugin for Android and iOS. Additional setup and instructions can be found here. Be sure to read this documentation to understand Firebase messaging functionality.

Once that's done, FCM should be able to send push notifications to your devices.

Integration With Stream
Step 1 - Get the Firebase Credentials
These credentials are the private key file for your service account, in Firebase console.

To generate a private key file for your service account in the Firebase console:

Open Settings > Service Accounts.

Click Generate New Private Key, then confirm by clicking Generate Key.

Securely store the JSON file containing the key.

This JSON file contains the credentials that need to be uploaded to Stream’s server, as explained in the next step.

Step 2 - Upload the Firebase Credentials to Stream
You can upload your Firebase credentials using either the dashboard or the app settings API (available only in backend SDKs).

Using the Stream Dashboard
Go to the Chat Overview page on Stream Dashboard.

Enable Firebase Notification toggle on Chat Overview.

Enter your Firebase Credentials and press "Save".
Using the API
You can also enable Firebase notifications and upload the Firebase credentials using one of our server SDKs.

For example, using the Stream JavaScript SDK:


const client = StreamChat.getInstance('api_key', 'api_secret');
client.updateAppSettings({
  push_config: {
    version: 'v2'
  },
  firebase_config: {
    credentials_json: fs.readFileSync(
      './firebase-credentials.json',
      'utf-8',
    ),
 });
Registering a Device With Stream Backend
Once you configure a Firebase server key and set it up on the Stream dashboard, a device that is supposed to receive push notifications needs to be registered on the Stream backend. This is usually done by listening for Firebase device token updates and passing them to the backend as follows:


firebaseMessaging.onTokenRefresh.listen((token) {
      client.addDevice(token, PushProvider.firebase);
});
Push Notifications v2 also supports specifying a name for the push device tokens you register. By setting the optional pushProviderName parameter in the addDevice call, you can support different configurations between the device and the PushProvider.


firebaseMessaging.onTokenRefresh.listen((token) {
      client.addDevice(token, PushProvider.firebase, pushProviderName: 'my-custom-config');
});
Receiving Notifications
Push notifications behave differently depending on whether you are using iOS or Android. See here to understand the difference between notification and data payloads.

iOS
On iOS, we send both a notification and a data payload. This means you don't need to do anything special to get the notification to show up. However, you might want to handle the data payload to perform some logic when the user taps on the notification.

To update the template, you can use a backend SDK. For example, using the Stream JavaScript SDK:


const client = StreamChat.getInstance(‘api_key’, ‘api_secret’);
const apn_template = `{
  "aps": {
    "alert": {
      "title": "New message from {{ sender.name }}",
      "body": "{{ truncate message.text 2000 }}"
    },
    "mutable-content": 1,
    "category": "stream.chat"
  },
  "stream": {
    "sender": "stream.chat",
      "type": "message.new",
      "version": "v2",
      "id": "{{ message.id }}",
      "cid": "{{ channel.cid }}"
  }
}`;
client.updateAppSettings({
  firebase_config: {
    apn_template,
 });
Android
On Android, we send only a data payload. This gives you more flexibility and lets you decide what to do with the notification.

For example, you can listen and generate a notification from them.

The code below demonstrates how to generate a notification when a data-only message is received and the app is in the background.

There are a few things to keep in mind about your background message handler:

It must not be an anonymous function.
It must be a top-level function (not a class method which requires initialization).
It must be annotated with @pragma('vm:entry-point') right above the function declaration (otherwise it may be removed during tree shaking for release mode).
For additional information on background messages, please see the Firebase documentation.


@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  final chatClient = StreamChatClient(apiKey);
  chatClient.connectUser(
    User(id: userId),
    userToken,
    connectWebSocket: false,
  );
  handleNotification(message, chatClient);
}
void handleNotification(
  RemoteMessage message,
  StreamChatClient chatClient,
) async {
  final data = message.data;
  if (data['type'] == 'message.new') {
    final flutterLocalNotificationsPlugin = await setupLocalNotifications();
    final messageId = data['id'];
    final response = await chatClient.getMessage(messageId);
    flutterLocalNotificationsPlugin.show(
      1,
      'New message from ${response.message.user!.name} in ${response.channel!.name}',
      response.message.text,
      const NotificationDetails(
          android: AndroidNotificationDetails(
        'new_message',
        'New message notifications channel',
      )),
    );
  }
}
FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
In the above example, you get the message details using the getMessage method, and then you use the flutter_local_notifications package to show the actual notification.

Using a Template on Android
Adding a notification payload to Android notifications is still possible. You can do so by adding a template using a backend SDK. For example, using the Stream JavaScript SDK:


const client = StreamChat.getInstance(‘api_key’, ‘api_secret’);
const notification_template = `
{
    "title": "{{ sender.name }} @ {{ channel.name }}",
    "body": "{{ message.text }}",
    "click_action": "OPEN_ACTIVITY_1",
    "sound": "default"
}`;
client.updateAppSettings({
  firebase_config: {
    notification_template,
 });
Possible Issues
Make sure to read the general push notification docs to prevent common issues with notifications 😢.

Testing if Push Notifications are Setup Correctly
If you're not sure whether you've set up push notifications correctly, for example, you don't always receive them, or they don’t work reliably, then you can follow these steps to make sure your configuration is correct and working:

Clone our repository for push testing: git clone git@github.com:GetStream/chat-push-test.git
cd chat-push-test/flutter
In that folder run flutter pub get
Input your API key and secret in lib/main.dart
Change the bundle identifier/application ID and development team/user so you can run the app on your physical device.Do not run on an iOS simulator, as it will not work. Testing on an Android emulator is fine.
Add your google-services.json/GoogleService-Info.plist
Run the app
Accept push notification permission (iOS only)
Tap on Device ID and copy it
After configuring stream-cli, run the following command using your user ID:

stream chat:push:test -u <USER-ID>
You should get a test push notification 🥳

Foreground Notifications
You may want to show a notification when the app is in the foreground. For example, when you're in a channel and receive a new message from someone in another channel.

For this scenario, you can also use the flutter_local_notifications package to show a notification.

You need to listen for new events using FirebaseMessaging.onMessage.listen() and handle them accordingly:


FirebaseMessaging.onMessage.listen((message) async {
  handleNotification(
    message,
    chatClient,
  );
});
You should also check that the message's channel differs from the channel in the foreground. How you do this depends on your app infrastructure and how you handle navigation.

Take a look at the Stream Chat v1 sample app to see how we're doing it over there.

Saving Notification Messages to the Offline Storage (Only Android)
When the app is closed, you can save incoming messages when you receive them via a notification so that they're already there later when you open the app.

To do this, you need to integrate the package stream_chat_persistence that exports a persistence client. See here for information on how to set it up.

Then calling FirebaseMessaging.onBackgroundMessage(...) you need to use a TOP-LEVEL or STATIC function to handle background messages.

For additional information on background messages, please see the Firebase documentation.

Here is an example:


@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  final chatClient = StreamChatClient(apiKey);
  final persistenceClient = StreamChatPersistenceClient();
  await persistenceClient.connect(userId);
  chatClient.connectUser(
    User(id: userId),
    userToken,
    connectWebSocket: false,
  );
  handleNotification(message, chatClient);
}
void handleNotification(
  RemoteMessage message,
  StreamChatClient chatClient,
) async {
  final data = message.data;
  if (data['type'] == 'message.new') {
    final flutterLocalNotificationsPlugin = await setupLocalNotifications();
    final messageId = data['id'];
    final cid = data['cid'];
    final response = await chatClient.getMessage(messageId);
    await persistenceClient.updateMessages(cid, [response.message]);
    persistenceClient.disconnect();
    flutterLocalNotificationsPlugin.show(
      1,
      'New message from ${response.message.user.name} in ${response.channel.name}',
      response.message.text,
      NotificationDetails(
          android: AndroidNotificationDetails(
        'new_message',
        'New message notifications channel',
      )),
    );
  }
}
FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);



Legacy
Adding Push Notifications To Your Application

Version 1 (legacy) of push notifications won't be removed immediately but there won't be any new features. That's why new applications are highly recommended to use version 2 from the beginning to leverage upcoming new features.

Introduction
Push notifications are a core part of the experience for a messaging app. Users often need to be notified of new messages and old notifications sometimes need to be updated silently as well.

This guide details how to add push notifications to your app.

Make sure to check this section of the docs to read about the push delivery logic.

Setup FCM
To integrate push notifications in your Flutter app you need to use the package firebase_messaging.

Follow the Firebase documentation to know how to set up the plugin for both Android and iOS.

Once that's done FCM should be able to send push notifications to your devices.

Integration with Stream
Step 1
From the Firebase Console, select the project your app belongs to.

Step 2
Click on the gear icon next to Project Overview and navigate to Project settings


Step 3
Navigate to the Cloud Messaging tab

Step 4
Under Project Credentials, locate the Server key and copy it


Step 5
Upload the Server Key in your chat dashboard



We are setting up the Android section, but this will work for both Android and iOS if you're using Firebase for both of them.

Step 6
Save your push notification settings changes


OR

Upload the Server Key via API call using a backend SDK


await client.updateAppSettings({
  firebase_config: {
    server_key: "server_key",
    notification_template: `{"message":{"notification":{"title":"New messages","body":"You have {{ unread_count }} new message(s) from {{ sender.name }}"},"android":{"ttl":"86400s","notification":{"click_action":"OPEN_ACTIVITY_1"}}}}`,
    data_template: `{"sender":"{{ sender.id }}","channel":{"type": "{{ channel.type }}","id":"{{ channel.id }}"},"message":"{{ message.id }}"}`,
  },
});
Registering a device at Stream Backend
Once you configure Firebase server key and set it up on Stream dashboard a device that is supposed to receive push notifications needs to be registered at Stream backend. This is usually done by listening for Firebase device token updates and passing them to the backend as follows:


firebaseMessaging.onTokenRefresh.listen((token) {
      client.addDevice(token, PushProvider.firebase);
});
Possible issues
We only send push notifications when the user doesn't have any active web socket connection (which is established when you call client.connectUser). If you set the onBackgroundEventReceived property of the StreamChat widget, when your app goes to background, your device will keep the WS connection alive for 1 minute, and so within this period, you won't receive any push notification.

Make sure to read the general push docs in order to avoid known gotchas that may make your relationship with notifications go bad 😢

Testing if Push Notifications are Setup Correctly
If you're not sure if you've set up push notifications correctly (for example you don't always receive them, they work unreliably), you can follow these steps to make sure your configuration is correct and working:

Clone our repository for push testing git clone git@github.com:GetStream/chat-push-test.git

cd flutter

In folder run flutter pub get

Input your API key and secret in lib/main.dart

Change the bundle identifier/application ID and development team/user so you can run the app in your device (do not run on iOS simulator, Android emulator is fine)

Add your google-services.json/GoogleService-Info.plist

Run the app

Accept push notification permission (iOS only)

Tap on Device ID and copy it

Send the app to background

After configuring stream-cli paste the following command on command line using your user ID


stream chat:push:test -u <USER-ID>
You should get a test push notification

App in the background but still connected
The StreamChat widget lets you define a onBackgroundEventReceived handler in order to handle events while the app is in the background, but the client is still connected.

This is useful because it lets you keep the connection alive in cases in which the app goes in the background just for some seconds (for example multitasking, picking pictures from the gallery...)

You can even customize the backgroundKeepAlive duration.

In order to show notifications in such a case we suggest using the package flutter_local_notifications; follow the package guide to successfully set up the plugin.

Once that's done you should set the onBackgroundEventReceived; here is an example:


...
StreamChat(
  client: client,
  onBackgroundEventReceived: (e) {
    final currentUserId = client.state.user.id;
    if (![
          EventType.messageNew,
          EventType.notificationMessageNew,
        ].contains(event.type) ||
        event.user.id == currentUserId) {
      return;
    }
    if (event.message == null) return;
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final initializationSettingsAndroid =
        AndroidInitializationSettings('launch_background');
    final initializationSettingsIOS = IOSInitializationSettings();
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    await flutterLocalNotificationsPlugin.show(
      event.message.id.hashCode,
      event.message.user.name,
      event.message.text,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'message channel',
          'Message channel',
          'Channel used for showing messages',
          priority: Priority.high,
          importance: Importance.high,
        ),
        iOS: IOSNotificationDetails(),
      ),
    );
  },
  child: ....
);
...
As you can see we generate a local notification whenever a message.new or notification.message_new event is received.

Foreground notifications
Sometimes you may want to show a notification when the app is in the foreground. For example, when you're in a channel and you receive a new message from someone in another channel.

For this scenario, you can also use the flutter_local_notifications package to show a notification.

You need to listen for new events using StreamChatClient.on and handle them accordingly.

Here we're checking if the event is a message.new or notification.message_new event, and if the message is from a different user than the current user. In that case we'll show a notification.


client.on(
  EventType.messageNew,
  EventType.notificationMessageNew,
).listen((event) {
  if (event.message?.user?.id == client.state.currentUser?.id) {
    return;
  }
  showLocalNotification(event, client.state.currentUser!.id, context);
});
You should also check that the channel of the message is different than the channel in the foreground. How you do this depends on your app infrastructure and how you handle navigation. Take a look at the Stream Chat v1 sample app to see how we're doing it over there.

Saving notification messages to the offline storage
You may want to save received messages when you receive them via a notification so that later on when you open the app they're already there.

To do this we need to update the push notification data payload at Stream Dashboard and clear the notification one:


{
  "message_id": "{{ message.id }}",
  "channel_id": "{{ channel.id }}",
  "channel_type": "{{ channel.type }}"
}
Then we need to integrate the package stream_chat_persistence in our app that exports a persistence client, learn here how to set it up.

Then during the call firebaseMessaging.configure(...) we need to set the onBackgroundMessage parameter using a TOP-LEVEL or STATIC function to handle background messages; here is an example:


Future<dynamic> myBackgroundMessageHandler(message) async {
  if (message.containsKey('data')) {
    final data = message['data'];
    final messageId = data['message_id'];
    final channelId = data['channel_id'];
    final channelType = data['channel_type'];
    final cid = '$channelType:$channelId';
    final client = StreamChatClient(apiKey);
    final persistenceClient = StreamChatPersistenceClient();
    await persistenceClient.connect(userId);
    final message = await client.getMessage(messageId).then((res) => res.message);
    await persistenceClient.updateMessages(cid, [message]);
    persistenceClient.disconnect();
    /// This can be done using the package flutter_local_notifications as we did before 👆
    _showLocalNotification();
  }
}
Did you find this page helpful?


Encryption
Adding End To End Encryption to your Chat App

Introduction
When you communicate over a chat application with another person or group, you may exchange sensitive information, like personally identifiable information, financial details, or passwords. A chat application should use end-to-end encryption to ensure that users' data stays secure.

Before you start, keep in mind that this guide is a basic example intended for educational purposes only. If you want to implement end-to-end encryption in your production app, please consult a security professional first. There’s a lot more to consider from a security perspective that isn’t covered here.

What is End-to-End Encryption?
End-to-end encryption (E2EE) is the process of securing a message from third parties so that only the sender and receiver can access the message. E2EE provides security by storing the message in an encrypted form on the application's server or database.

You can only access the message by decrypting and signing it using a known public key (distributed freely) and a corresponding private key (only known by the owner).

Each user in the application has their own public-private key pair. Public keys are distributed publicly and encrypt the sender’s messages. The receiver can only decrypt the sender’s message with the matching private key.

Check out the diagram below for an example:


Setup
Dependencies
Add the webcrypto package in your pubspec.yaml file.


dependencies:
  webcrypto: ^0.5.2 # latest version
Generate Key Pair
Write a function that generates a key pair using the ECDH algorithm and the P-256 elliptic curve (P-256 is well-supported and offers the right balance of security and performance).

The pair will consist of two keys:

PublicKey: The key that is linked to a user to encrypt messages.
PrivateKey: The key that is stored locally to decrypt messages.

Future<JsonWebKeyPair> generateKeys() async {
  final keyPair = await EcdhPrivateKey.generateKey(EllipticCurve.p256);
  final publicKeyJwk = await keyPair.publicKey.exportJsonWebKey();
  final privateKeyJwk = await keyPair.privateKey.exportJsonWebKey();
  return JsonWebKeyPair(
    privateKey: json.encode(privateKeyJwk),
    publicKey: json.encode(publicKeyJwk),
  );
}
// Model class for storing keys
class JsonWebKeyPair {
  const JsonWebKeyPair({
    required this.privateKey,
    required this.publicKey,
  });
  final String privateKey;
  final String publicKey;
}
Generate a Cryptographic Key
Next, create a symmetric Cryptographic Key using the keys generated in the previous step. You will use those keys to encrypt and decrypt messages.


// SendersJwk -> sender.privateKey
// ReceiverJwk -> receiver.publicKey
Future<List<int>> deriveKey(String senderJwk, String receiverJwk) async {
  // Sender's key
  final senderPrivateKey = json.decode(senderJwk);
  final senderEcdhKey = await EcdhPrivateKey.importJsonWebKey(
    senderPrivateKey,
    EllipticCurve.p256,
  );
  // Receiver's key
  final receiverPublicKey = json.decode(receiverJwk);
  final receiverEcdhKey = await EcdhPublicKey.importJsonWebKey(
    receiverPublicKey,
    EllipticCurve.p256,
  );
  // Generating CryptoKey
  final derivedBits = await senderEcdhKey.deriveBits(256, receiverEcdhKey);
  return derivedBits;
}
Encrypting Messages
Once you have generated the Cryptographic Key, you're ready to encrypt the message. You can use the AES-GCM algorithm for its known security and performance balance and good browser availability.


// The "iv" stands for initialization vector (IV). To ensure the encryption’s strength,
// each encryption process must use a random and distinct IV.
// It’s included in the message so that the decryption procedure can use it.
final Uint8List iv = Uint8List.fromList('Initialization Vector'.codeUnits);

Future<String> encryptMessage(String message, List<int> deriveKey) async {
  // Importing cryptoKey
  final aesGcmSecretKey = await AesGcmSecretKey.importRawKey(deriveKey);
  // Converting message into bytes
  final messageBytes = Uint8List.fromList(message.codeUnits);
  // Encrypting the message
  final encryptedMessageBytes =
      await aesGcmSecretKey.encryptBytes(messageBytes, iv);
  // Converting encrypted message into String
  final encryptedMessage = String.fromCharCodes(encryptedMessageBytes);
  return encryptedMessage;
}
Decrypting Messages
Decrypting a message is the opposite of encrypting one. To decrypt a message to a human-readable format, use the code snippet below:


Future<String> decryptMessage(String encryptedMessage, List<int> deriveKey) async {
  // Importing cryptoKey
  final aesGcmSecretKey = await AesGcmSecretKey.importRawKey(deriveKey);
  // Converting message into bytes
  final messageBytes = Uint8List.fromList(encryptedMessage.codeUnits);
  // Decrypting the message
  final decryptedMessageBytes =
      await aesGcmSecretKey.decryptBytes(messageBytes, iv);
  // Converting decrypted message into String
  final decryptedMessage = String.fromCharCodes(decryptedMessageBytes);
  return decryptedMessage;
}
Implement as a Stream Chat Feature
Now that your setup is complete you can use it to implement end-to-end encryption in your app.

Store User's Public Key
The first thing you need to do is store the generated publicKey as an extraData property, in order for other users to encrypt messages.


// Generating keyPair using the function defined in above steps
final keyPair = generateKeys();

await client.connectUser(
  User(
    id: 'cool-shadow-7',
    name: 'Cool Shadow',
    image: 'https://getstream.io/cool-shadow',
    // set publicKey as a extraData property
    extraData: { 'publicKey': keyPair.publicKey },
  ),
  client.devToken('cool-shadow-7').rawValue,
);
Sending Encrypted Messages
Now you will use the encryptMessage() function created in the previous steps to encrypt the message.

To do that, you need to make some minor changes to the StreamMessageInput widget.


final receiverJwk = receiver.extraData['publicKey'];
// Generating derivedKey using user's privateKey and receiver's publicKey
final derivedKey = await deriveKey(keyPair.privateKey, receiverJwk);

StreamMessageInput(
  ...
  preMessageSending: (message) async {
    // Encrypting the message text using derivedKey
    final encryptedMessage = await encryptMessage(message.text, derivedKey);
    // Creating a new message with the encrypted message text
    final newMessage = message.copyWith(text: encryptedMessage);
    return newMessage;
  },
),
preMessageSending is a parameter that allows your app to process the message before it goes to Stream’s server. Here, you have used it to encrypt the message before sending it to Stream’s backend.

Showing Decrypted Messages
Now, it’s time to decrypt the message and present it in a human-readable format to the receiver.

You can customize the StreamMessageListView widget to have a custom messagebuilder, that can decrypt the message.


StreamMessageListView(
  ...
  messageBuilder: (context, messageDetails, currentMessages, defaultWidget) {
    // Retrieving the message from details
    final message = messageDetails.message;
    // Decrypting the message text using the derivedKey
    final decryptedMessageFuture = decryptMessage(message.text, derivedKey);
    return FutureBuilder<String>(
      future: decryptedMessageFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        if (!snapshot.hasData) return Container();
        // Updating the original message with the decrypted text
        final decryptedMessage = message.copyWith(text: snapshot.data);
        // Returning defaultWidget with updated message
        return defaultWidget.copyWith(
          message: decryptedMessage,
        );
      },
    );
  },
),
That's it. That's all you need to implement E2EE in a Stream powered chat app.


Authentication
Securely generate Stream Chat user tokens using Firebase Authentication and Cloud Functions.

This guide assumes that you are familiar with Firebase Authentication and Cloud Functions for Flutter and using the Flutter Stream Chat SDK.

Introduction
In this guide, you'll explore how you can use Firebase Auth as an authentication provider and create Firebase Cloud functions to securely generate Stream Chat user tokens.

You will use Stream's NodeJS client for Stream account creation and token generation, and Flutter Cloud Functions for Firebase to invoke the cloud functions from your Flutter app.

Stream supports several different backend clients to integrate with your server. This guide only shows an easy way to integrate Stream Chat authentication using Firebase and Flutter.

Flutter Firebase
See the Flutter Firebase getting started docs for setup and installation instructions.

You will also need to add the Flutter Firebase Authentication, and Flutter Firebase Cloud Functions packages to your app. Depending on the platform that you target, there may be specific configurations that you need to do.

Starting Code
The following code shows a basic application with FirebaseAuth and FirebaseFunctions.

You will extend this later to execute cloud functions.


import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'dart:async';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Auth(),
      ),
    );
  }
}
class Auth extends StatefulWidget {
  const Auth({super.key});
  @override
  _AuthState createState() => _AuthState();
}
class _AuthState extends State<Auth> {
  late firebase_auth.FirebaseAuth auth;
  late FirebaseFunctions functions;
  @override
  void initState() {
    super.initState();
    auth = firebase_auth.FirebaseAuth.instance;
    functions = FirebaseFunctions.instance;
  }
  final email = 'test@getstream.io';
  final password = 'password';
  Future<void> createAccount() async {
    // Create Firebase account
    await auth.createUserWithEmailAndPassword(email: email, password: password);
    print('Firebase account created');
  }
  Future<void> signIn() async {
    // Sign in with Firebase
    await auth.signInWithEmailAndPassword(email: email, password: password);
    print('Firebase signed in');
  }
  Future<void> signOut() async {
    // Revoke Stream chat token.
    final callable = functions.httpsCallable('revokeStreamUserToken');
    await callable();
    print('Stream user token revoked');
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AuthenticationState(
            streamUser: auth.authStateChanges().map(
                  (firebaseUser) => firebaseUser != null
                      ? User(
                          id: firebaseUser.uid,
                          // Map other user fields here
                        )
                      : null,
                ),
          ),
          ElevatedButton(
            onPressed: createAccount,
            child: const Text('Create account'),
          ),
          ElevatedButton(
            onPressed: signIn,
            child: const Text('Sign in'),
          ),
          ElevatedButton(
            onPressed: signOut,
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}
class AuthenticationState extends StatelessWidget {
  const AuthenticationState({
    super.key,
    required this.streamUser,
  });
  final Stream<User?> streamUser;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: streamUser,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return (snapshot.data != null)
              ? const Text('Authenticated')
              : const Text('Not Authenticated');
        }
        return const Text('Not Authenticated');
      },
    );
  }
}
Running the above will give this:


The Auth widget handles all of the authentication logic. It initializes a FirebaseAuth.instance and uses that in the createAccount, signIn and signOut methods. There is a button to invoke each of these methods.

The FirebaseFunctions.instance will be used later in this guide.

The AuthenticationState`` widget listens toauth.authStateChanges()(mapped to Stream'sUser`) to display a message indicating if a user is authenticated.

Firebase Cloud Functions
Firebase Cloud Functions allows you to extend Firebase with custom operations that an event can trigger:

Internal event: For example, when creating a new Firebase account this is automatically triggered.
External event: For example, directly calling a cloud function from your Flutter application.
To set up your local environment to deploy cloud functions, please see the Cloud Functions getting started docs.

After initializing your project with cloud functions, you should have a functions folder in your project, including a package.json file.

There should be two dependencies already added, firebase-admin and firebase-functions. You will also need to add the stream-chat dependency.

Navigate to the functions folder and run npm install stream-chat --save-prod.

This will install the node module and add it as a dependency to package.json.

Now open index.js and add the following (this is the complete example):


const StreamChat = require("stream-chat").StreamChat;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const serverClient = StreamChat.getInstance(
  functions.config().stream.key,
  functions.config().stream.secret,
);
// When a user is deleted from Firebase their associated Stream account is also deleted.
exports.deleteStreamUser = functions.auth.user().onDelete((user, context) => {
  return serverClient.deleteUser(user.uid);
});
// Create a Stream user and return auth token.
exports.createStreamUserAndGetToken = functions.https.onCall(
  async (data, context) => {
    // Checking that the user is authenticated.
    if (!context.auth) {
      // Throwing an HttpsError so that the client gets the error details.
      throw new functions.https.HttpsError(
        "failed-precondition",
        "The function must be called " + "while authenticated.",
      );
    } else {
      try {
        // Create user using the serverClient.
        await serverClient.upsertUser({
          id: context.auth.uid,
          name: context.auth.token.name,
          email: context.auth.token.email,
          image: context.auth.token.image,
        });
        /// Create and return user auth token.
        return serverClient.createToken(context.auth.uid);
      } catch (err) {
        console.error(
          `Unable to create user with ID ${context.auth.uid} on Stream. Error ${err}`,
        );
        // Throwing an HttpsError so that the client gets the error details.
        throw new functions.https.HttpsError(
          "aborted",
          "Could not create Stream user",
        );
      }
    }
  },
);
// Get Stream user token.
exports.getStreamUserToken = functions.https.onCall((data, context) => {
  // Checking that the user is authenticated.
  if (!context.auth) {
    // Throwing an HttpsError so that the client gets the error details.
    throw new functions.https.HttpsError(
      "failed-precondition",
      "The function must be called " + "while authenticated.",
    );
  } else {
    try {
      return serverClient.createToken(context.auth.uid);
    } catch (err) {
      console.error(
        `Unable to get user token with ID ${context.auth.uid} on Stream. Error ${err}`,
      );
      // Throwing an HttpsError so that the client gets the error details.
      throw new functions.https.HttpsError(
        "aborted",
        "Could not get Stream user",
      );
    }
  }
});
// Revoke the authenticated user's Stream chat token.
exports.revokeStreamUserToken = functions.https.onCall((data, context) => {
  // Checking that the user is authenticated.
  if (!context.auth) {
    // Throwing an HttpsError so that the client gets the error details.
    throw new functions.https.HttpsError(
      "failed-precondition",
      "The function must be called " + "while authenticated.",
    );
  } else {
    try {
      return serverClient.revokeUserToken(context.auth.uid);
    } catch (err) {
      console.error(
        `Unable to revoke user token with ID ${context.auth.uid} on Stream. Error ${err}`,
      );
      // Throwing an HttpsError so that the client gets the error details.
      throw new functions.https.HttpsError(
        "aborted",
        "Could not get Stream user",
      );
    }
  }
});
First, you import the necessary packages and call admin.initializeApp(); to set up Firebase cloud functions.

Next, you initialize the StreamChat server client by calling StreamChat.getInstance. This function requires your Stream app's token and secret. You can get this from the Stream Dashboard for your app.

Set these values as environment data on Firebase Functions.


firebase functions:config:set stream.key="app-key" stream.secret="app-secret"
Replace app-key and app-secret with the values for your Stream app.

This creates an object of stream with properties key and secret. To access this environment data use functions.config().stream.key and functions.config().stream.secret.

See the Firebase environment configuration documentation for additional information.

To deploy these functions to Firebase, run:


firebase deploy --only functions
Create a Stream User and Get the User's Token
In the createStreamUserAndGetToken cloud function you create an onCall HTTPS handler, which exposes a cloud function that can be invoked from your Flutter app.


// Create a Stream user and return auth token.
exports.createStreamUserAndGetToken = functions.https.onCall(
  async (data, context) => {
    // Checking that the user is authenticated.
    if (!context.auth) {
      // Throwing an HttpsError so that the client gets the error details.
      throw new functions.https.HttpsError(
        "failed-precondition",
        "The function must be called " + "while authenticated.",
      );
    } else {
      try {
        // Create user using the serverClient.
        await serverClient.upsertUser({
          id: context.auth.uid,
          name: context.auth.token.name,
          email: context.auth.token.email,
          image: context.auth.token.image,
        });
        /// Create and return user auth token.
        return serverClient.createToken(context.auth.uid);
      } catch (err) {
        console.error(
          `Unable to create user with ID ${context.auth.uid} on Stream. Error ${err}`,
        );
        // Throwing an HttpsError so that the client gets the error details.
        throw new functions.https.HttpsError(
          "aborted",
          "Could not create Stream user",
        );
      }
    }
  },
);
This function first does a check to see that the client that calls it is authenticated, by ensuring that context.auth is not null. If it is null, then it throws an HttpsError with a descriptive message. This error can be caught in your Flutter application.

If the caller is authenticated the function proceeds to use the serverClient to create a new Stream Chat user by calling the upsertUser method and passing in some user data. It uses the authenticated caller's uid as an id.

After the user is created it generates a token for that user. This token is then returned to the caller.

To call this from Flutter, you will need to use the cloud_functions package.

Update the createAccount method in your Flutter code to the following:


Future<void> createAccount() async {
  // Create Firebase account
  await auth.createUserWithEmailAndPassword(email: email, password: password);
  print('Firebase account created');
  // Create Stream user and get token
  final callable = functions.httpsCallable('createStreamUserAndGetToken');
  final results = await callable();
  print('Stream account created, token: ${results.data}');
}
Calling this method will do the following:

Create a new Firebase User and authenticate that user.
Call the createStreamUserAndGetToken cloud function and get the Stream user token for the authenticated user.
As you can see, calling a cloud function is easy and will also send all the necessary user authentication information (such as the UID) in the request.

Once you have the Stream user token, you can authenticate your Stream Chat user as you normally would.

Please see our initialization documentation for more information.

As you can see below, the User ID matches on both Firebase's and Stream's user database.

Firebase Authentication Database
Firebase Auth Database with new user created
Stream Chat User Database
Stream chat user database new account created
Get the Stream User Token
The getStreamUserToken cloud function is very similar to the createStreamUserAndGetToken function. The only difference is that it only creates a user token and does not create a new user account on Stream.

Update the signIn method in your Flutter code to the following:


Future<void> signIn() async {
  // Sign in with Firebase
  await auth.signInWithEmailAndPassword(email: email, password: password);
  print('Firebase signed in');
  // Get Stream user token
  final callable = functions.httpsCallable('getStreamUserToken');
  final results = await callable();
  print('Stream user token retrieved: ${results.data}');
}
Calling this method will do the following:

Sign in using Firebase Auth.
Call the getStreamUserToken cloud function to get a Stream user token.
The user needs to be authenticated to call this cloud function. Otherwise, the function will throw the failed-precondition error that you specified.

Revoke Stream User Token
You may also want to revoke the Stream user token if you sign out from Firebase.

Update the signOut method in your Flutter code to the following:


Future<void> signOut() async {
  // Revoke Stream user token.
  final callable = functions.httpsCallable('revokeStreamUserToken');
  await callable();
  print('Stream user token revoked');
  // Sign out Firebase.
  await auth.signOut();
  print('Firebase signed out');
}
Call the cloud function before signing out from Firebase.

Delete Stream User
When deleting a Firebase user account, it would make sense also to delete the associated Stream user account.

The cloud function looks like this:


// When a user is deleted from Firebase their associated Stream account is also deleted.
exports.deleteStreamUser = functions.auth.user().onDelete((user, context) => {
  return serverClient.deleteUser(user.uid);
});
In this function, you are listening to delete events on Firebase auth. When an account is deleted, this function will be triggered, and you can get the user's uid and call the deleteUser method on the serverClient.

This is not an external cloud function; it can only be triggered when an account is deleted.

Conclusion
In this guide, you have seen how to securely create Stream Chat tokens using Firebase Authentication and Cloud Functions.

The principles shown in this guide can be applied to your preferred authentication provider and cloud architecture of choice.


Error Reporting
Error Reporting With Sentry

Introduction
While one always tries to create apps that are free of bugs, they're sure to crop up from time to time. Since buggy apps lead to unhappy users and customers, it's important to understand how often your users experience bugs and where those bugs occur. That way, you can prioritize the bugs with the highest impact and work to fix them.

Whenever an error occurs, create a report containing the error that occurred and the associated stack trace. You can then send the report to an error tracking service, such as Sentry, Rollbar, or Firebase Crashlytics.

The error tracking service aggregates all of the crashes your users experience and groups them together. This allows you to know how often your app fails and where your users run into trouble.

In this guide, learn how to report Stream Chat errors to the Sentry crash reporting service using the following steps.

1. Get a DSN From Sentry
Before reporting errors to Sentry, you need a “DSN” to uniquely identify your app with the Sentry service: To get a DSN, use the following steps:

Create an account with Sentry.
Log in to the account.
Create a new Flutter project.
Copy the code snippet that includes the DSN.
2. Import the Sentry package
Import the sentry_flutter package into your app. The sentry package makes it easier to send error reports to the Sentry error tracking service.


dependencies:
  sentry_flutter: <latest_version>
3. Initialize the Sentry SDK
Initialize the SDK to capture different unhandled errors automatically.


import 'package:sentry_flutter/sentry_flutter.dart';
Future<void> main() async {
  await SentryFlutter.init(
    (options) => options.dsn = 'https://example@sentry.io/example',
    appRunner: () => runApp(const MyApp()),
  );
}
Or, if you want to run your app in your own error zone, use runZonedGuarded:


void main() async {
  /// Captures errors reported by the Flutter framework.
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      // In development mode, simply print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production mode, report to the application zone to report to Sentry.
      Zone.current.handleUncaughtError(details.exception, details.stack!);
    }
  };
  Future<void> _reportError(dynamic error, StackTrace stackTrace) async {
    // Print the exception to the console.
    if (kDebugMode) {
      // Print the full stack trace in debug mode.
      print(stackTrace);
      return;
    } else {
      // Send the Exception and Stacktrace to sentry in Production mode.
      await Sentry.captureException(error, stackTrace: stackTrace);
    }
  }
  runZonedGuarded(
    () async {
      await SentryFlutter.init(
        (options) => options.dsn = 'https://example@sentry.io/example',
      );
      runApp(const MyApp());
    },
    _reportError,
  );
}
Alternatively, you can pass the DSN to Flutter using the dart-define tag:


--dart-define SENTRY_DSN=https://example@sentry.io/example
4. Integration With StreamChat Applications
Override the default logHandlerFunction to send errors to Sentry.


void sampleAppLogHandler(LogRecord record) async {
  if (kDebugMode) StreamChatClient.defaultLogHandler(record);
  // Report errors to Sentry
  if (record.error != null || record.stackTrace != null) {
    await Sentry.captureException(
      record.error,
      stackTrace: record.stackTrace,
    );
  }
}
StreamChatClient buildStreamChatClient(
  String apiKey, {
  Level logLevel = Level.SEVERE,
}) {
  return StreamChatClient(
    apiKey,
    logLevel: logLevel,
    logHandlerFunction: sampleAppLogHandler, // Pass the overridden logHandlerFunction
  );
}
5. Capture Errors Programmatically
Besides the automatic error reporting that Sentry generates by importing and initializing the SDK, you can use the API to manually report errors to Sentry:


await Sentry.captureException(exception, stackTrace: stackTrace);
For more information, see the Sentry API docs on Pub.

Complete Example
To view a working example, see the Stream Sample app.

Learn More
Extensive documentation about using the Sentry SDK can be found on Sentry's site.


Chat Messaging
/
Docs
/
Flutter
/
Initialize Stream Chat in Part of the Widget Tree
Initialize Stream Chat in Part of the Widget Tree
If you’re creating a full-scale chat application, you probably want to have Stream Chat Flutter initialized at the top of your widget tree and the Stream user connected as soon as they open the application.

However, if you only need chat functionality in a part of your application, then it’ll be better to delay Stream Chat initialization to when it’s needed. This guide demonstrates three alternative ways for you to initialize Stream Chat Flutter for a part of your widget tree and to only connect a user when needed.

What To Keep In Mind?
Before investigating potential solutions, let’s first take a look at the relevant Stream Chat widgets and classes.

Most of the Stream Chat Flutter UI widgets rely on having a StreamChat ancestor in the widget tree. The StreamChat widget is an InheritedWidget that exposes the StreamChatClient through BuildContext. This widget also initializes the StreamChatCore widget and the StreamChatTheme.

StreamChatCore is a StatefulWidget used to react to life cycle changes and system updates. When the app goes into the background, the WebSocket connection is closed. Conversely, a new connection is initiated when the app is back in the foreground.

What is important to take note of is that a connection is only established if a user is connected.

This means that if you have not yet called client.connectUser(user, token), no connection will be made, and only background listeners will be registered to determine the app's foreground state.

Option 1: Builder and Connect/Disconnect User
This option requires you to wrap your whole application with the StreamChat widget and to call connectUser and disconnectUser as needed.

This option is the easiest, however, it requires StreamChat to be at the top of each route and as a result, will have a slight overhead as it’ll create the above-mentioned Stream widgets that may not yet be needed.

Exposing the StreamChat Widget
First, you must expose the client and base Stream Chat widgets to the whole application.


void main() {
  final client = StreamChatClient(
    'q29npdvqjr99',
    logLevel: Level.OFF,
  );
  runApp(MyApp(client: client));
}
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.client,
  });
  final StreamChatClient client;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return StreamChat(client: client, child: child);
      },
      home: const HomeScreen(),
    );
  }
}
In the above code, you:

Create a StreamChatClient instance
Pass the instance to the StreamChat widget
Expose StreamChat to the whole application within the MaterialApp builder
A few important things to note:

The builder wraps the StreamChat widget for every route of our application. No matter where you are in the widget tree, you’ll be able to call StreamChat.of(context).
The state will only be created once for our application, as StreamChat is a StatefulWidget and the position of StreamChat in the widget tree remains the same throughout the application lifecycle.
No connection will be made until you call connectUser.
Connecting and Disconnecting Users
In MaterialApp above, the home page is set to HomeScreen. This screen could look something like the following:


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Text('Home Screen'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ChatSetup()));
        },
        child: const Icon(
          Icons.message,
        ),
      ),
    );
  }
}
This screen shows a floating action button that on click navigates the user to the ChatSetup. We want to connect and disconnect a Stream user only when they go to the chat setup screen.


class ChatSetup extends StatefulWidget {
  const ChatSetup({
    super.key,
  });
  @override
  State<ChatSetup> createState() => _ChatSetupState();
}
class _ChatSetupState extends State<ChatSetup> {
  late final Future<OwnUser> connectionFuture;
  late final client = StreamChat.of(context).client;
  @override
  void initState() {
    super.initState();
    connectionFuture = client.connectUser(
      User(id: 'USER_ID'),
      'TOKEN',
    );
  }
  @override
  void dispose() {
    client.disconnectUser();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: connectionFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            default:
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return const ChannelListPage();
              }
          }
        },
      ),
    );
  }
}
Within initState you call connectUser; once the future for connectUser has completed a connection to the Stream API is established, you can then display the relevant Stream Chat UI widgets.

Once the ChatScreen widget is disposed of, then disconnectUser will be called within the dispose method.

Caution
In this example, disconnectUser will only be called when the ChatSetup widget is disposed.

You need to ensure that this widget (route) is completely disposed of, or you need to call disconnectUser and connectUser manually when navigating to relevant parts of your application.

For example, let’s say you have a button within one of the chat screens to navigate to a completely different part of your app, then you want to make sure the ChatScreen route is disposed of by forcing it to be removed:


Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(
    builder: ((context) => const HomeScreen()),
  ),
  (Route<dynamic> route) => false,
);
Or let’s say you wanted to pop back to the first route:


Navigator.of(context).popUntil((route) => route.isFirst);
Both of these will ensure the route is disposed of and the user is disconnected as a result.

Option 2: A Nested Navigator
Another approach would be to introduce a new Navigator. This has the benefit that everything related to Stream chat is contained to a specific part of the widget tree.

Defining Routes and Nested Routes
In this example, our application has the following routes.


const routeHome = '/';
const routePrefixChat = '/chat/';
const routeChatHome = '$routePrefixChat$routeChatChannels';
const routeChatChannels = 'chat_channels';
const routeChatChannel = 'chat_channel';
For the /chat/ nested routes (routePrefixChat), this approach initializes Stream Chat in our application and introduces a nested navigator.

Let’s explore the code:


void main() {
  runApp(const MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });
  @override
  State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: navigatorKey,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        initialRoute: routeHome,
        onGenerateRoute: (settings) {
          late Widget page;
          if (settings.name == routeHome) {
            page = const HomeScreen();
          } else if (settings.name!.startsWith(routePrefixChat)) {
            final subRoute = settings.name!.substring(routePrefixChat.length);
            page = ChatSetup(
              setupChatRoute: subRoute,
            );
          } else {
            throw Exception('Unknown route: ${settings.name}');
          }
          return MaterialPageRoute<dynamic>(
            builder: (context) {
              return page;
            },
            settings: settings,
          );
        },
      ),
    );
  }
}
In the above code you’re:

Creating a navigator key, passing it to MaterialApp, and exposing it to the whole application using Provider (you can expose it however you want).
Creating onGenerateRoute that specifies what page to show depending on the route. Most importantly, if the route contains the routePrefixChat, it navigates to the ChatSetup page and passes in the remainder of the route.
For example, Navigator.pushNamed(context, routeChatHome) will navigate to the ChatSetup page and pass in the nested route routeChatChannels.

Stream Chat Initialization, User Connection, and Nested Navigation
Within the ChatSetup widget, we’ll initialize Stream chat, connect a user, and create a new Navigator that handles the sub-navigation for the chat-specific pages.


class ChatSetup extends StatefulWidget {
  const ChatSetup({super.key, required this.setupChatRoute});
  final String setupChatRoute;
  @override
  State<ChatSetup> createState() => _ChatSetupState();
}
class _ChatSetupState extends State<ChatSetup> {
  late final Future<OwnUser> connectionFuture;
  late final client = StreamChatClient(
    'KEY',
    logLevel: Level.OFF,
  );
  @override
  void initState() {
    super.initState();
    connectionFuture = client.connectUser(
      User(id: 'USER_ID'),
      'TOKEN',
    );
  }
  @override
  void dispose() {
    client.disconnectUser();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      child: StreamChat(
        client: client,
        child: FutureBuilder(
          future: connectionFuture,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              default:
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Navigator(
                    initialRoute: widget.setupChatRoute,
                    onGenerateRoute: _onGenerateRoute,
                  );
                }
            }
          },
        ),
      ),
    );
  }
  Route _onGenerateRoute(RouteSettings settings) {
    late Widget page;
    switch (settings.name) {
      case routeChatChannels:
        page = ChannelListPage(
          client: client,
        );
        break;
      case routeChatChannel:
        final channel = settings.arguments as Channel;
        page = StreamChannel(
          channel: channel,
          child: const ChannelPage(),
        );
        break;
      default:
        throw Exception('Unknown route: ${settings.name}');
    }
    return MaterialPageRoute<dynamic>(
      builder: (context) {
        return page;
      },
      settings: settings,
    );
  }
}
This ChatSetup widget is similar to what it was in the first option, the only difference is that we’re also introducing a nested navigator and handling those nested routes.

The steps for the above code are:

Create a StreamChatClient instance
Call connectUser within initState and await the result using a FutureBuilder
Introduce a StreamChat widget into the widget tree
Introduce a new Navigator for the chat-specific routes
Call disconnectUser within dispose
Displaying Stream Chat UI Widgets and Global Navigation
Then finally, the ChannelListPage could look something like the following:


class ChannelListPage extends StatefulWidget {
  const ChannelListPage({
    super.key,
    required this.client,
  });
  final StreamChatClient client;
  @override
  State<ChannelListPage> createState() => _ChannelListPageState();
}
class _ChannelListPageState extends State<ChannelListPage> {
  late final _controller = StreamChannelListController(
    client: widget.client,
    filter: Filter.in_(
      'members',
      [StreamChat.of(context).currentUser!.id],
    ),
    channelStateSort: const [SortOption('last_message_at')],
  );
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  void _popChatPages() {
    final nav = context.read<GlobalKey<NavigatorState>>();
    nav.currentState!.pop();
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) _popChatPages();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              _popChatPages();
            },
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _controller.refresh,
          child: StreamChannelListView(
            controller: _controller,
            onChannelTap: (channel) {
              Navigator.pushNamed(context, routeChatChannel,
                  arguments: channel);
            },
          ),
        ),
      ),
    );
  }
}
There are two important things to note in the above code:

We’re accessing the global NavigatorState using Provider and calling pop() on the back press. This will ensure that this entire route is disposed of and that the Stream connection is closed.
Within onChannelTap we’re calling pushNamed and passing in the route to display a single channel page. This uses the navigator introduced in ChatSetup, which is the closest navigator within the widget tree.
A few things to take note of:

You’ll always need to access the global navigator if you want to dispose of this route. you need to ensure that this route is popped or replaced, otherwise, the Stream connection will remain active for as long as the chat route is on the stack (or manually disconnected).
Option 3: Navigator 2.0 - Using GoRouter
This final example will be a combination of the first two options. The following code is an example of how to initialize Stream Chat in a part of the widget tree using the GoRouter package. This solution will change depending on how you do routing in your Flutter application and which package (if any) you use.

Application Routes and Conditional Stream Initialization
For this example we have the following routes and nested routes:


|_ '/' -> home page
	|_ 'settings/' - settings page
	|_ 'chat/' - chat home, shows the channels list page
		|_ 'channel/' - specific channel page
In the MyApp widget, we’ll initialize GoRouter and the StreamChatClient. However, we will only expose the StreamChat widget for certain routes. Additionally, we’ll create a ChatSetup widget that connects and disconnects the user. This widget will also only be injected for the /chat routes.


class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });
  @override
  State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  final _client = StreamChatClient(
    'q29npdvqjr99',
    logLevel: Level.OFF,
  );
  bool wasPreviousRouteChat = false;
  late final _router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          if (state.uri.host.startsWith('/chat')) {
            wasPreviousRouteChat = true;
            return StreamChat(
              client: _client,
              child: ChatSetup(client: _client, child: child),
            );
          } else {
            if (wasPreviousRouteChat) {
              wasPreviousRouteChat = false;
              return StreamChat(
                client: _client,
                child: child,
              );
            } else {
              return child;
            }
          }
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'settings',
                builder: (context, state) => const SettingsPage(),
              ),
              GoRoute(
                path: 'chat',
                builder: (context, state) => const ChannelListPage(),
                routes: [
                  GoRoute(
                    path: 'channel',
                    builder: (context, state) {
                      final channel = state.extra as Channel;
                      return StreamChannel(
                        channel: channel,
                        child: const ChannelPage(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: _router.routeInformationParser,
      routeInformationProvider: _router.routeInformationProvider,
      routerDelegate: _router.routerDelegate,
    );
  }
}
If you’re unfamiliar with GoRouter it will help to first read the documentation and then come back to this guide.

There are a few important things to note in the above code:

Define our routes and nested routes
Specify the initial route with initialLocation
Use the navigatorBuilder to wrap certain routes with StreamChat and ChatSetup.
The wasPreviousRouteChat **boolean is used to determine if the previous route was a chat route. This is important because when you press the back button from the /chat route and navigate to the / route, theStreamChatwidget still needs to be accessible while the navigation transition occurs. However, if you then navigate to the /setting route, you no longer need theStreamChat** widget and can safely remove it.
Navigating With GoRouter
Within the HomeScreen you can create a button that on press navigates to the /chat route:


GoRouter.of(context).go('/chat');
Connecting and Disconnecting Users
Same as before, we’ll use the ChatSetup widget to connect and disconnect a user. This time the widget also takes in a child widget to display once the connection is finished. The child widget is dependent on the route we’re navigating to.


class ChatSetup extends StatefulWidget {
  const ChatSetup({
    super.key,
    required this.client,
    required this.child,
  });
  final StreamChatClient client;
  final Widget child;
  @override
  State<ChatSetup> createState() => _ChatSetupState();
}
class _ChatSetupState extends State<ChatSetup> {
  late final Future<OwnUser> connectionFuture;
  @override
  void initState() {
    super.initState();
    connectionFuture = widget.client.connectUser(
      User(id: 'USER_ID'),
      'TOKEN',
    );
  }
  @override
  void dispose() {
    widget.client.disconnectUser();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      child: FutureBuilder(
        future: connectionFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            default:
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return widget.child;
              }
          }
        },
      ),
    );
  }
}
This will connect the Stream chat user within initState and disconnect the user on dispose. This is similar to the previous examples we explored.

Displaying the Stream UI Widgets
The ChannelListPage can look something like the following:


class ChannelListPage extends StatefulWidget {
  const ChannelListPage({
    super.key,
  });
  @override
  State<ChannelListPage> createState() => _ChannelListPageState();
}
class _ChannelListPageState extends State<ChannelListPage> {
  late final client = StreamChat.of(context).client;
  late final _controller = StreamChannelListController(
    client: client,
    filter: Filter.in_(
      'members',
      [StreamChat.of(context).currentUser!.id],
    ),
    channelStateSort: const [SortOption('last_message_at')],
  );
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: RefreshIndicator(
        onRefresh: _controller.refresh,
        child: StreamChannelListView(
          controller: _controller,
          onChannelTap: (channel) {
            GoRouter.of(context).go('/chat/channel', extra: channel);
          },
        ),
      ),
    );
  }
}
This is the same as before, the only difference is that the navigation is slightly different; now we’re navigating to the /chat/channel route for individual channel pages.

Conclusion
This guide demonstrated three different ways to initialize Stream Chat in a part of the Flutter widget tree.

There are two key takeaways

Accessing StreamChat depends on your location in the widget tree
How you ultimately decide to expose StreamChat and connect users will be up to your application architecture and how you manage routing.
The above are only examples that can be refined and tweaked to suit your needs.