#!/bin/sh

keychain_password="admin"
keychain_path="~/Library/Keychains/login.keychain-db"

function unlock_keychain {
    security unlock-keychain -p $keychain_password $keychain_path
}
