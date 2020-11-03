package me.schlaubi

import io.ktor.application.*
import io.ktor.features.*
import io.ktor.http.*
import io.ktor.http.cio.websocket.*
import io.ktor.response.*
import io.ktor.routing.*
import io.ktor.serialization.*
import io.ktor.websocket.*
import kotlinx.serialization.json.Json
import kotlinx.serialization.modules.plus
import java.time.Duration

/**
 * Program entry point
 */
fun main(args: Array<String>): Unit = io.ktor.server.netty.EngineMain.main(args)

/**
 * Json serializer used for whole project
 */
val json: Json = Json {
    isLenient = true
    ignoreUnknownKeys = true

    classDiscriminator = "op"

    serializersModule = PacketModule + UUIDModule
}

/**
 * Module entry point.
 */
@Suppress("unused", "UNUSED_PARAMETER") // Referenced in application.conf
@kotlin.jvm.JvmOverloads
fun Application.module(testing: Boolean = false) {
    install(WebSockets) {
        pingPeriod = Duration.ofSeconds(15)
        timeout = Duration.ofSeconds(15)
        maxFrameSize = Long.MAX_VALUE
        masking = false
    }

    install(CORS) {
        allowCredentials = true
        allowNonSimpleContentTypes = true
        allowSameOrigin = true
        header(HttpHeaders.Authorization)
        anyHost()
        method(HttpMethod.Delete)
        method(HttpMethod.Get)
        method(HttpMethod.Patch)
        method(HttpMethod.Put)
        method(HttpMethod.Post)
    }

    install(ContentNegotiation) {
        json(json)
    }

    routing {
        get("/") {
            call.respondText(
                "Kotlin + Ktor > Go! Sorry Google. I mean you also contribute to Kotlin soooo uhm",
                contentType = ContentType.Text.Plain
            )
        }

        channels()
    }
}
