#!/usr/bin/env python3
# coding: utf-8
# [c] https://gist.github.com/dannycolin/e8f21f1de40ab19875fcb6962f2817e0

from urllib.parse import urlparse
import requests
import sys
import time

def get_all_followers(instance, account):
    url = "https://" + instance + "/api/v1/accounts/" + account + "/followers"
    while url:
        response = requests.get(url)
        assert response is not None and response.status_code == 200
        url = response.links.get("next", {}).get("url")
        for user in response.json():
            acct = user["acct"]
            if "@" not in acct:
                acct += "@" + instance
            print(acct)
        sys.stdout.flush()
        # try to be nice and not hammer the API
        time.sleep(5)
