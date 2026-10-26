// SPDX-License-Identifier: Apache-2.0
package org.pixelos.nabu.usb;

import java.io.IOException;
import java.util.Arrays;

/** One bounded authentication attempt. No HID enable/disable or firmware writes. */
public final class KeyboardAuth {
    public enum Result {
        ONLINE_VERIFIED, OFFLINE_VERIFIED_RECHECK, REJECTED,
        TRANSFER_ERROR, PROTOCOL_ERROR, AUTHORITY_UNAVAILABLE, INTERNAL_ERROR
    }
    public interface Transport {
        /** Returns only bytes actually received, never an untrimmed receive buffer. */
        byte[] exchange(byte[] command) throws IOException;
    }
    public interface Authority {
        byte[] chooseKey(byte[] uid, byte[] first, byte[] second) throws IOException;
        byte[] getChallenge(int size) throws IOException;
        int verify(int type, byte[] uid, byte[] key, byte[] challenge, byte[] token)
                throws IOException;
    }
    private KeyboardAuth() {}

    public static Result verifyOnce(Transport transport, Authority authority) {
        if (transport == null || authority == null) return Result.AUTHORITY_UNAVAILABLE;
        byte[] init = null, uid = null, first = null, second = null;
        byte[] key = null, challenge = null, tokenReply = null, token = null, command = null;
        try {
            try { init = transport.exchange(initCommand()); }
            catch (IOException e) { return Result.TRANSFER_ERROR; }
            if (!validResponse(init, 0x31, 26)) return Result.PROTOCOL_ERROR;
            uid = Arrays.copyOfRange(init, 8, 24);
            first = Arrays.copyOfRange(init, 24, 28);
            second = Arrays.copyOfRange(init, 28, 32);
            // Pass copies: a failed/buggy IPC adapter must not mutate the offered identity.
            key = authority.chooseKey(uid.clone(), first.clone(), second.clone());
            if (key != null && key.length == 0) return Result.REJECTED;
            if (key == null || key.length != 4) return Result.INTERNAL_ERROR;
            if (!Arrays.equals(key, first) && !Arrays.equals(key, second))
                return Result.INTERNAL_ERROR;
            challenge = authority.getChallenge(16);
            if (challenge == null || challenge.length != 16) return Result.INTERNAL_ERROR;
            command = challengeCommand(key, challenge);
            try { tokenReply = transport.exchange(command); }
            catch (IOException e) { return Result.TRANSFER_ERROR; }
            if (!validResponse(tokenReply, 0x32, 16)) return Result.PROTOCOL_ERROR;
            token = Arrays.copyOfRange(tokenReply, 6, 22);
            int result = authority.verify(1, uid, key, challenge, token);
            if (result == 1) return Result.ONLINE_VERIFIED;
            if (result == 2) return Result.OFFLINE_VERIFIED_RECHECK;
            if (result == 3) return Result.INTERNAL_ERROR;
            return Result.REJECTED;
        } catch (IOException e) {
            return Result.AUTHORITY_UNAVAILABLE;
        } finally {
            // No UID/challenge/token logging, broadcasting, or retention by this layer.
            for (byte[] bytes : new byte[][]{init, uid, first, second, key, challenge,
                    tokenReply, token, command}) if (bytes != null) Arrays.fill(bytes, (byte) 0);
        }
    }

    public static byte[] initCommand() {
        byte[] command = {0x4f, 0x31, (byte) 0x80, 0x38, 0x31, 6,
                'M', 'I', 'A', 'U', 'T', 'H', 0};
        command[12] = checksum(command, 12);
        return command;
    }
    public static byte[] challengeCommand(byte[] key, byte[] challenge) {
        if (key == null || key.length != 4 || challenge == null || challenge.length != 16)
            throw new IllegalArgumentException("Expected 4-byte key metadata and 16-byte challenge");
        byte[] command = new byte[27];
        command[0] = 0x4f; command[1] = 0x31; command[2] = (byte) 0x80;
        command[3] = 0x38; command[4] = 0x32; command[5] = 20;
        System.arraycopy(key, 0, command, 6, 4);
        System.arraycopy(challenge, 0, command, 10, 16);
        command[26] = checksum(command, 26);
        return command;
    }
    public static boolean validResponse(byte[] response, int command, int payloadSize) {
        // Report/routing bytes 0..3 need an official-device capture; do not invent them.
        // These packets are framing only. Authenticity is decided by the stock authority.
        if (!((command == 0x31 && payloadSize == 26) || (command == 0x32 && payloadSize == 16)))
            return false;
        int end = 6 + payloadSize;
        return response != null && response.length >= end + 1 && response.length <= 64
                && (response[4] & 255) == command && (response[5] & 255) == payloadSize
                && checksum(response, end) == response[end];
    }
    static byte checksum(byte[] bytes, int length) {
        int result = 0;
        for (int i = 0; i < length; ++i) result += bytes[i] & 255;
        return (byte) result;
    }
    static boolean authCommand(byte[] command) {
        if (command == null) return false;
        if (Arrays.equals(command, initCommand())) return true;
        return command.length == 27 && command[0] == 0x4f && command[1] == 0x31
                && (command[2] & 255) == 0x80 && command[3] == 0x38
                && command[4] == 0x32 && command[5] == 20
                && checksum(command, 26) == command[26];
    }
}
