# mongol_bichig
Кирилл, Монгол бичгийн мессенжер апп

APK
32 bit : flutter build apk --release

------------------- TABLES -------------------

users
    uid (UID PK)
    email (String)
    name (String)

peers
    id (UID PK)
    fromUserId (UID FK)
    fromUserName (String)
    peerUserId (UID FK)
    peerUserName (String)
    createdAt (Timestamp)
    userIds ([UID])

messages
    id (UID PK)
    peerId (UID FK)
    fromUserId (UID FK)
    fromUserName (String)
    peerUserId (String)
    peerUserName (String)
    message (String)
    createdAt (Timestamp)