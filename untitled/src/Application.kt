package me.schlaubi

import io.ktor.application.*
import io.ktor.features.*
import io.ktor.http.*
import io.ktor.http.cio.websocket.*
import io.ktor.response.*
import io.ktor.routing.*
import io.ktor.websocket.*
import org.json.JSONObject
import java.time.Duration

fun main(args: Array<String>): Unit = io.ktor.server.netty.EngineMain.main(args)

private val clients = mutableListOf<DefaultWebSocketSession>()

@Suppress("unused") // Referenced in application.conf
@kotlin.jvm.JvmOverloads
fun Application.module(testing: Boolean = false) {
    install(WebSockets) {
        pingPeriod = Duration.ofSeconds(15)
        timeout = Duration.ofSeconds(15)
        maxFrameSize = Long.MAX_VALUE
        masking = false
    }

    install(ContentNegotiation) {
    }

    routing {
        get("/") {
            call.respondText("HELLO WORLD!", contentType = ContentType.Text.Plain)
        }

        webSocket("/ws") {
            val name = call.request.queryParameters["name"]
            if (name.isNullOrBlank()) {
                close(CloseReason(CloseReason.Codes.CANNOT_ACCEPT, "Missing name"))
                return@webSocket
            }

            println("New session: $this")

            clients.add(this)
            while (true) {
                val frame = incoming.receive()
                if (frame is Frame.Text) {
                    val content = frame.readText()
                    println("Got packet $content")
                    val json = JSONObject(content)
                    val data = json.getJSONObject("d")
                    when (json.getString("op")) {
                        "close" -> {
                            clients.remove(this)
                            close(CloseReason(CloseReason.Codes.NORMAL, "Requested by user"))
                        }
                        "messageCreate" -> {
                            val content = data.getString("content")
                            clients.forEach {
                                val obj = mapOf(
                                        "op" to "messageReceive",
                                        "d" to mapOf(
                                                "content" to content,
                                                "author" to name
                                        )
                                )
                                it.send(Frame.Text(JSONObject(obj).toString()))
                            }
                        }
                    }
                }
            }
        }
    }
}
