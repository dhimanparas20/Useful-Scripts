import pika
from typing import Callable, Optional, Any

class RabbitMQQueue:
    """
    Production-ready RabbitMQ queue handler for CloudAMQP or any AMQP broker.
    """

    def __init__(self, amqp_url: str, queue_name: str, durable: bool = True) -> None:
        """
        Initialize the queue handler and connect to the broker.

        Args:
            amqp_url (str): AMQP connection URL.
            queue_name (str): Name of the queue.
            durable (bool): Whether the queue should survive broker restarts.
        """
        self.amqp_url = amqp_url
        self.queue_name = queue_name
        self.durable = durable
        self.connection = None
        self.channel = None
        self._connect()

    def _connect(self) -> None:
        """Establish connection and channel, declare the queue."""
        params = pika.URLParameters(self.amqp_url)
        self.connection = pika.BlockingConnection(params)
        self.channel = self.connection.channel()
        self.channel.queue_declare(queue=self.queue_name, durable=self.durable)

    def produce(self, message: str, persistent: bool = True) -> None:
        """
        Publish a message to the queue.

        Args:
            message (str): The message to send.
            persistent (bool): Make message survive broker restarts.
        """
        props = pika.BasicProperties(delivery_mode=2) if persistent else None
        self.channel.basic_publish(
            exchange='',
            routing_key=self.queue_name,
            body=message,
            properties=props
        )

    def consume(self, callback: Callable[[str], Any], auto_ack: bool = False, prefetch: int = 1) -> None:
        """
        Start consuming messages from the queue.

        Args:
            callback (Callable[[str], Any]): Function to process each message body (as string).
            auto_ack (bool): Whether to automatically acknowledge messages.
            prefetch (int): Number of messages to prefetch (for fair dispatch).
        """
        def _internal_callback(ch, method, properties, body):
            callback(body.decode())
            if not auto_ack:
                ch.basic_ack(delivery_tag=method.delivery_tag)

        self.channel.basic_qos(prefetch_count=prefetch)
        self.channel.basic_consume(
            queue=self.queue_name,
            on_message_callback=_internal_callback,
            auto_ack=auto_ack
        )
        print(f"[*] Waiting for messages in '{self.queue_name}'. To exit press CTRL+C")
        self.channel.start_consuming()

    def get(self, auto_ack: bool = True) -> Optional[str]:
        """
        Get a single message from the queue (non-blocking).

        Args:
            auto_ack (bool): Whether to automatically acknowledge the message.

        Returns:
            Optional[str]: The message body, or None if queue is empty.
        """
        method_frame, header_frame, body = self.channel.basic_get(self.queue_name, auto_ack=auto_ack)
        if method_frame:
            return body.decode()
        return None

    def purge(self) -> None:
        """Remove all messages from the queue."""
        self.channel.queue_purge(self.queue_name)

    def close(self) -> None:
        """Close the channel and connection."""
        if self.channel:
            self.channel.close()
        if self.connection:
            self.connection.close()

    def queue_size(self) -> int:
        """Return the number of messages in the queue."""
        q = self.channel.queue_declare(queue=self.queue_name, durable=self.durable, passive=True)
        return q.method.message_count

# --- Example Usage ---

if __name__ == "__main__":
    AMQP_URL = "amqps://hxssuxdc:YOUR_PASSWORD@puffin.rmq2.cloudamqp.com/hxssuxdc"
    QUEUE_NAME = "test_queue"

    # Producer example
    queue = RabbitMQQueue(AMQP_URL, QUEUE_NAME)
    for i in range(5):
        queue.produce(f"Hello from class-based producer! Message {i}")
    print(f"Queue size after produce: {queue.queue_size()}")
    queue.close()

    # Consumer example
    def process_message(msg):
        print(f"Consumed: {msg}")

    queue = RabbitMQQueue(AMQP_URL, QUEUE_NAME)
    queue.consume(process_message)  # This will block and consume messages
    queue.close()
