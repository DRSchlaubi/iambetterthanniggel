package me.schlaubi

import io.ktor.application.*
import io.ktor.auth.*
import io.ktor.http.*
import io.ktor.http.auth.*
import io.ktor.http.cio.websocket.*
import io.ktor.request.*
import io.ktor.response.*
import io.ktor.routing.*
import io.ktor.util.*
import io.ktor.util.pipeline.*
import io.ktor.websocket.*
import kotlinx.coroutines.launch
import java.util.*

private val channels =
    mutableMapOf<UUID, Channel>(with(UUID.randomUUID()) { this to Channel("Default Channel", this) })

/**
 * /channels route.
 */
fun Routing.channels() {
    route("/channels") {
        listChannels()
        createChannel()
        channelManagement()
    }
}

private fun Route.channelManagement() {
    route("{channelId}") {
        get("/messages") {
            withChannelUser { channel, _ ->
                context.respond(channel.messages)
            }
        }

        post("/messages") {
            withChannelUser { channel, user ->
                val content = context.receiveText()
                channel.newMessage(user, content)
                context.respond(HttpStatusCode.Accepted)
            }
        }

        webSocket("/ws") {
            val channelId =
                call.request.call.parameters["channelId"]?.let { UUID.fromString(it) }
                    ?: error("Missing channel id")
            val channel = channels[channelId]
            if (channel == null) {
                close(CloseReason(CloseReason.Codes.CANNOT_ACCEPT, "Invalid channel id"))
                return@webSocket
            }
            val name = call.request.queryParameters["name"]
            if (name.isNullOrBlank()) {
                close(CloseReason(CloseReason.Codes.CANNOT_ACCEPT, "Missing name"))
                return@webSocket
            }

            channel.join(this, name, false)
        }
    }
}

private fun Route.createChannel() {
    webSocket("new") {
        val name = call.request.queryParameters["name"]
        if (name.isNullOrBlank()) {
            close(CloseReason(CloseReason.Codes.CANNOT_ACCEPT, "Missing name"))
            return@webSocket
        }

        val channelName = call.request.queryParameters["channel_name"]
        if (name.isNullOrBlank()) {
            close(CloseReason(CloseReason.Codes.CANNOT_ACCEPT, "Missing channel_name"))
            return@webSocket
        }

        @Suppress("ReplaceNotNullAssertionWithElvisReturn") // see check above
        val newChannel = Channel(channelName!!)
        channels[newChannel.id] = newChannel

        newChannel.join(this@webSocket, name, true)
    }
}

private fun Route.listChannels() {
    get {
        context.respond(channels.values.toList())
    }
}

@OptIn(KtorExperimentalAPI::class)
private suspend inline fun PipelineContext<*, ApplicationCall>.withChannelUser(block: (Channel, Channel.User) -> Unit) {
    val channelId =
        context.parameters["channelId"]?.let { UUID.fromString(it) }
            ?: error("Missing channel id")
    val channel =
        channels[channelId] ?: return context.respond(HttpStatusCode.NotFound, "Invalid Channel")
    val authHeader = context.request.parseAuthorizationHeader() ?: return context.respond(
        HttpStatusCode.Unauthorized,
        "Missing auth header"
    )

    if (authHeader !is HttpAuthHeader.Single) {
        return context.respond(
            HttpStatusCode.Unauthorized,
            "Invalid auth header"
        )
    }

    val key = authHeader.blob
    val user = channel.findUserByKey(key) ?: return context.respond(HttpStatusCode.Forbidden, "Unauthorized key")

    return block(channel, user)
}
