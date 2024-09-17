import asyncio
import aiohttp
import argparse
import time
import ssl
import statistics
import socket
from collections import Counter
from urllib.parse import urlparse

async def fetch(session, url, timeout):
    start_time = time.time()
    try:
        async with session.get(url, timeout=timeout, ssl=False) as response:
            await response.read()
            return {
                'status': response.status,
                'time': time.time() - start_time,
                'url': str(response.url),
                'error': None
            }
    except asyncio.TimeoutError:
        return {'status': 0, 'time': time.time() - start_time, 'url': url, 'error': 'Timeout'}
    except aiohttp.ClientError as e:
        return {'status': 0, 'time': time.time() - start_time, 'url': url, 'error': str(e)}
    except Exception as e:
        return {'status': 0, 'time': time.time() - start_time, 'url': url, 'error': str(e)}

async def load_test(url, concurrent, requests, timeout):
    connector = aiohttp.TCPConnector(ssl=False, limit=concurrent)
    async with aiohttp.ClientSession(connector=connector) as session:
        tasks = [fetch(session, url, timeout) for _ in range(requests)]
        return await asyncio.gather(*tasks)

def print_summary(results):
    total_time = sum(r['time'] for r in results)
    successful = sum(1 for r in results if 200 <= r['status'] < 300)
    failed = len(results) - successful

    print("\nSummary:")
    print(f"Requests per second: {len(results) / total_time:.2f}")
    print(f"Average time per request: {total_time / len(results):.2f}s")
    print(f"Successful requests: {successful}")
    print(f"Failed requests: {failed}")
    print(f"Failure rate: {failed / len(results) * 100:.2f}%")

    if failed > 0:
        print("\nError Details:")
        errors = Counter(r['error'] for r in results if r['error'])
        for error, count in errors.most_common():
            print(f"  {count}: {error}")

        print("\nStatus Code Distribution:")
        statuses = Counter(r['status'] for r in results)
        for status, count in statuses.most_common():
            print(f"  HTTP {status}: {count}")

        print("\nResponse Time Statistics:")
        times = [r['time'] for r in results]
        print(f"  Min: {min(times):.3f}s")
        print(f"  Max: {max(times):.3f}s")
        print(f"  Mean: {statistics.mean(times):.3f}s")
        print(f"  Median: {statistics.median(times):.3f}s")
        print(f"  95th percentile: {statistics.quantiles(times, n=20)[-1]:.3f}s")

def perform_dns_check(url):
    parsed_url = urlparse(url)
    hostname = parsed_url.hostname
    print(f"\nDNS Resolution for {hostname}:")
    try:
        ip_address = socket.gethostbyname(hostname)
        print(f"  Resolved IP: {ip_address}")
    except socket.gaierror as e:
        print(f"  DNS resolution failed: {e}")

def perform_ssl_check(url: str) -> None:
    parsed_url = urlparse(url)
    hostname = parsed_url.hostname
    port = parsed_url.port or 443
    print(f"\nSSL Certificate Check for {hostname}:")
    try:
        context = ssl.create_default_context()
        with socket.create_connection((hostname, port)) as sock:
            with context.wrap_socket(sock, server_hostname=hostname) as secure_sock:
                cert = secure_sock.getpeercert()
                if cert is None:
                    print("Error: Unable to retrieve peer certificate")
                else:
                    print(f"  Subject: {dict(x[0] for x in cert['subject'])}")
                    print(f"  Issuer: {dict(x[0] for x in cert['issuer'])}")
                    print(f"  Version: {cert['version']}")
                    print(f"  Serial Number: {cert['serialNumber']}")
                    print(f"  Not Before: {cert['notBefore']}")
                    print(f"  Not After: {cert['notAfter']}")
    except ssl.SSLError as e:
        print(f"  SSL certificate verification failed: {e}")
    except Exception as e:
        print(f"  Error during SSL check: {e}")

async def main():
    parser = argparse.ArgumentParser(description="Async Load Tester for Ingress-Nginx")
    parser.add_argument("-u", "--url", required=True, help="Target URL")
    parser.add_argument("-c", "--concurrent", type=int, default=10, help="Number of concurrent connections")
    parser.add_argument("-n", "--requests", type=int, default=1000, help="Total number of requests")
    parser.add_argument("-t", "--timeout", type=float, default=30, help="Timeout in seconds")
    args = parser.parse_args()

    print(f"Running load test with the following parameters:")
    print(f"URL: {args.url}")
    print(f"Concurrent connections: {args.concurrent}")
    print(f"Total requests: {args.requests}")
    print(f"Timeout: {args.timeout} seconds")
    print("Note: SSL certificate validation is disabled")

    perform_dns_check(args.url)
    perform_ssl_check(args.url)

    start_time = time.time()
    results = await load_test(args.url, args.concurrent, args.requests, args.timeout)
    total_time = time.time() - start_time

    print(f"\nTotal time: {total_time:.2f} seconds")
    print_summary(results)

if __name__ == "__main__":
    asyncio.run(main())
