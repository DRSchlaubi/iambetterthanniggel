package me.schlaubi

import io.ktor.http.cio.websocket.*
import io.ktor.util.*
import kotlinx.serialization.*
import mu.KotlinLogging
import java.util.*

private val LOG = KotlinLogging.logger { }

/**
 * Representation of a channel.
 *
 * @property name the name of the channel
 * @property id the unique id of the channel
 */
@Suppress("MemberVisibilityCanBePrivate")
@Serializable
class Channel(val name: String, @Contextual val id: UUID = UUID.randomUUID()) {
    /**
     * A list of all messages in this channel.
     */
    val messages: List<MessageCreatePacket.Data>
        get() = mutableMessages.toList()

    @Transient
    private val users = mutableListOf<User>()
    private val mutableMessages = mutableListOf<MessageCreatePacket.Data>()

    /**
     * Adds a news user by it's [session], [name] and [admin status](isAdmin) to this channel.
     */
    @OptIn(KtorExperimentalAPI::class)
    suspend fun join(session: DefaultWebSocketSession, name: String, isAdmin: Boolean = false) {
        val user = User(session, generateNonce(), name, isAdmin)
        users.add(user)

        newUser(user)

        for (frame in session.incoming) {
            LOG.info { "[WS - $id] Processing $frame" }
            if (frame is Frame.Text) {
                val packet = json.decodeFromString(
                    Packet.serializer(PolymorphicSerializer(Packet.Data::class)),
                    frame.readText()
                )
                handlePacket(packet, user)
            }
        } // if this loop ends the client disconnected

        // not gracefully disconnected
        if (user in users) {
            users.remove(user)
            broadcast(UserLeftPacket(UserLeftPacket.Data(user.toWebsocketUser())))
        }
    }

    /**
     * Creates a new message from [user] with [content].
     */
    suspend fun newMessage(user: User, content: String) {
        val newMessage = MessageCreatePacket.Data(content, user.name)

        mutableMessages.add(newMessage)

        broadcast(MessageCreatePacket(newMessage))
    }

    /**
     * Searches for a user corresponding to the [key].
     */
    fun findUserByKey(key: String): User? = users.firstOrNull {
        it.key == key
    }

    private suspend fun handlePacket(packet: Packet<*>, user: User) {
        LOG.info { "[WS - $id] ${user.nonce}: $packet" }
        when (packet) {
            is ClosePacket -> {
                users.remove(user)
                broadcast(
                    UserLeftPacket(
                        UserLeftPacket.Data(WebsocketUser(user.name, user.isAdmin, user.nonce))
                    )
                )
            }

            else -> {
                users.remove(user)
                user.session.close(CloseReason(CloseReason.Codes.PROTOCOL_ERROR, "Unknown packet"))
            }
        }
    }

    private suspend fun newUser(user: User) {
        LOG.info { "[WS - $id] New $user connected" }
        broadcast(
            UserJoinedPacket(
                UserJoinedPacket.Data(WebsocketUser(user.name, user.isAdmin, user.nonce))
            )
        )

        user.session.send(
            HelloPacket(
                HelloPacket.Data(id, user.toWebsocketUser(), user.key, name, users.map(User::toWebsocketUser))
            )
        )
    }

    /**
     * Representation of a user in the channel.
     *
     * @property session the [DefaultWebSocketSession] of the users connection
     * @property nonce a unique identifier of the user
     * @property name the name of the user
     * @property isAdmin whether the user is admin or not
     * @property key the authentication key of the user
     */
    data class User @OptIn(KtorExperimentalAPI::class) constructor(
        val session: DefaultWebSocketSession,
        val nonce: String = generateNonce(),
        val name: String,
        val isAdmin: Boolean,
        val key: String = generateNonce()
    ) {
        /**
         * Converts this into a [WebsocketUser].
         */
        fun toWebsocketUser(): WebsocketUser = WebsocketUser(name, isAdmin, nonce)
    }

    private suspend fun broadcast(packet: Packet<*>) {
        users.forEach { (session) ->
            session.send(packet)
        }
    }

    private suspend fun WebSocketSession.send(packet: Packet<out Packet.Data>) {
        val json = json.encodeToString(packet)
        return send(json)
    }
}
