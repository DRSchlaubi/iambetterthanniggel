package me.schlaubi

import kotlinx.serialization.*
import kotlinx.serialization.descriptors.PrimitiveKind
import kotlinx.serialization.descriptors.PrimitiveSerialDescriptor
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder
import kotlinx.serialization.modules.SerializersModule
import kotlinx.serialization.modules.polymorphic
import java.util.*

internal val PacketModule = SerializersModule {
    polymorphic(Packet::class) {
        subclass(ClosePacket::class, ClosePacket.serializer())
        subclass(MessageCreatePacket::class, MessageCreatePacket.serializer())
        subclass(UserJoinedPacket::class, UserJoinedPacket.serializer())
        subclass(UserLeftPacket::class, UserLeftPacket.serializer())
        subclass(HelloPacket::class, HelloPacket.serializer())
    }
}

/**
 * Represents a packet sent through the websocket containing payload [data].
 */
@Serializable
abstract class Packet<T : Packet.Data> {
    /**
     * The payload of the packet.
     */
    @SerialName("d")
    abstract val data: T

    /**
     * Interface for payload.
     */
    interface Data

    /**
     * Object for empty payload
     */
    @Serializable(with = EmptyDataSerializer::class)
    object EmptyData : Data

    /**
     * Representation of supported opcodes.
     */
    @Serializable
    @Suppress("EnumEntryName")
    enum class OPCode {
        /**
         * Gracefully closes the connection. Contains [EmptyData].
         */
        @SerialName("close")
        CLOSE,

        /**
         * Event stating that a new message was sent. Contains [MessageCreatePacket.Data].
         */
        @SerialName("messageCreate")
        MESSAGE_CREATE,

        /**
         * Event stating that a new user joined the room. Contains [UserJoinedPacket.Data].
         */
        @SerialName("userJoined")
        USER_JOINED,

        /**
         * Event stating that a new user joined the room. Contains [UserLeftPacket.Data].
         */
        @SerialName("userLeft")
        USER_LEFT,

        /**
         * Event stating that the client successfully connected to the socket. Contains [HelloPacket.Data].
         */
        @SerialName("hello")
        HELLO
    }
}

/**
 * Sent by: client
 * OPCode: [Packet.OPCode.CLOSE]
 * Command sent to gracefully close the current connection.
 */
@SerialName("close")
@Serializable
class ClosePacket : Packet<Packet.EmptyData>() {
    override val data: EmptyData = EmptyData
}

/**
 * Sent by: server
 * OPCode: [Packet.OPCode.MESSAGE_CREATE]
 * Event stating a new message has been created.
 */
@SerialName("messageCreate")
@Serializable
class MessageCreatePacket(@SerialName("d") override val data: Data) :
    Packet<MessageCreatePacket.Data>() {

    /**
     * @see Packet.OPCode.MESSAGE_CREATE
     * @param content the content of the message
     * @param author the author of the message
     */
    @Serializable
    data class Data(val content: String, val author: String) : Packet.Data
}

/**
 * Sent by: server
 * OPCode: [Packet.OPCode.USER_JOINED]
 * Event stating a new user joined the channel
 */
@SerialName("userJoined")
@Serializable
class UserJoinedPacket(@SerialName("d") override val data: Data) : Packet<UserJoinedPacket.Data>() {

    /**
     * @see Packet.OPCode.USER_JOINED
     * @param user the [WebsocketUser] that joined
     */
    @Serializable
    data class Data(val user: WebsocketUser) : Packet.Data
}

/**
 * Sent by: server
 * OPCode: [Packet.OPCode.USER_LEFT]
 * Event stating a user left the channel
 */
@SerialName("userLeft")
@Serializable
class UserLeftPacket(@SerialName("d") override val data: Data) : Packet<UserLeftPacket.Data>() {

    /**
     * @see Packet.OPCode.USER_JOINED
     * @param user the [WebsocketUser] that left
     */
    @Serializable
    data class Data(val user: WebsocketUser) : Packet.Data
}

/**
 * Sent by: server
 * OPCode: [Packet.OPCode.HELLO]
 * Welcome event sent to client to update channel info
 */
@SerialName("hello")
@Serializable
class HelloPacket(@SerialName("d") override val data: Data) : Packet<HelloPacket.Data>() {

    /**
     * @see Packet.OPCode.HELLO
     * @property user the user connected
     * @property key they auth key for this user
     * @property users a list of users in this channel
     * @property channelId the id of the channel you connected to
     * @property channelName the name of the channel the user connected to
     */
    @Serializable
    data class Data(
        @Contextual val channelId: UUID,
        val user: WebsocketUser,
        val key: String,
        val channelName: String,
        val users: List<WebsocketUser>
    ) : Packet.Data
}

/**
 * A user with a [name] and [admin status](isAdmin) and a unique [nonce].
 *
 * @property name the name of the user
 * @property isAdmin whether the user created this channel or not
 * @property nonce a unique identifier for the user
 */
@Serializable
data class WebsocketUser(val name: String, val isAdmin: Boolean, val nonce: String)

internal object EmptyDataSerializer : KSerializer<Packet.EmptyData> {
    override val descriptor: SerialDescriptor = PrimitiveSerialDescriptor("data", PrimitiveKind.STRING)

    override fun deserialize(decoder: Decoder): Packet.EmptyData = Packet.EmptyData

    @OptIn(ExperimentalSerializationApi::class)
    override fun serialize(encoder: Encoder, value: Packet.EmptyData): Unit = encoder.encodeNull()
}
