// SPDX-License-Identifier: Apache-2.0
package org.pixelos.nabu.usb;

import java.io.IOException;
import java.util.Arrays;
import java.util.Random;

/** Synthetic framing/workflow tests, not captured official-keyboard traffic. */
public final class KeyboardAuthTest {
    private static void check(boolean value) { if (!value) throw new AssertionError(); }
    private static byte[] sequence(int size, int start) {
        byte[] result = new byte[size];
        for (int i = 0; i < size; ++i) result[i] = (byte) (start + i);
        return result;
    }
    private static void seal(byte[] packet, int end) {
        int sum = 0;
        for (int i = 0; i < end; ++i) sum += packet[i] & 255;
        packet[end] = (byte) sum;
    }
    private static byte[] initReply() {
        byte[] packet = new byte[33]; packet[4] = 0x31; packet[5] = 26;
        System.arraycopy(sequence(16, 16), 0, packet, 8, 16);
        System.arraycopy(new byte[]{1, 2, 3, 4}, 0, packet, 24, 4);
        System.arraycopy(new byte[]{0x41, 5, 6, 7}, 0, packet, 28, 4);
        seal(packet, 32); return packet;
    }
    private static byte[] tokenReply() {
        byte[] packet = new byte[23]; packet[4] = 0x32; packet[5] = 16;
        System.arraycopy(sequence(16, 32), 0, packet, 6, 16);
        seal(packet, 22); return packet;
    }
    private static final class Transport implements KeyboardAuth.Transport {
        byte[] init = initReply(), token = tokenReply();
        int calls, failAt;
        @Override public byte[] exchange(byte[] command) throws IOException {
            if (++calls == failAt) throw new IOException("disconnected");
            check(KeyboardAuth.authCommand(command));
            if (calls == 1) {
                check(Arrays.equals(command, KeyboardAuth.initCommand())); return init.clone();
            }
            check(calls == 2 && Arrays.equals(command,
                    KeyboardAuth.challengeCommand(new byte[]{1, 2, 3, 4}, sequence(16, 0))));
            return token.clone();
        }
    }
    private static final class Authority implements KeyboardAuth.Authority {
        int verified, result = 1, failAt, calls;
        byte[] key = {1, 2, 3, 4}, challenge = sequence(16, 0);
        private void call() throws IOException { if (++calls == failAt) throw new IOException("binder died"); }
        @Override public byte[] chooseKey(byte[] uid, byte[] first, byte[] second) throws IOException {
            call(); check(Arrays.equals(uid, sequence(16, 16)));
            check(Arrays.equals(first, new byte[]{1, 2, 3, 4}));
            check(Arrays.equals(second, new byte[]{0x41, 5, 6, 7}));
            Arrays.fill(uid, (byte) 99); Arrays.fill(first, (byte) 99);
            return key == null ? null : key.clone();
        }
        @Override public byte[] getChallenge(int size) throws IOException {
            call(); check(size == 16); return challenge == null ? null : challenge.clone();
        }
        @Override public int verify(int type, byte[] uid, byte[] key, byte[] challenge, byte[] token)
                throws IOException {
            call(); ++verified;
            check(type == 1 && Arrays.equals(uid, sequence(16, 16)));
            check(Arrays.equals(key, new byte[]{1, 2, 3, 4}));
            check(Arrays.equals(challenge, sequence(16, 0)));
            check(Arrays.equals(token, sequence(16, 32))); return result;
        }
    }
    private static KeyboardAuth.Result run(Transport transport, Authority authority) {
        return KeyboardAuth.verifyOnce(transport, authority);
    }
    public static void main(String[] args) {
        check(Arrays.equals(KeyboardAuth.initCommand(), new byte[]{0x4f, 0x31, (byte) 0x80,
                0x38, 0x31, 6, 'M', 'I', 'A', 'U', 'T', 'H', 0x37}));
        byte[] challenge = KeyboardAuth.challengeCommand(new byte[]{1, 2, 3, 4}, sequence(16, 0));
        check(challenge.length == 27 && challenge[26] == 0);
        check(!KeyboardAuth.authCommand(new byte[]{0x4f, 0x31, (byte) 0x80, 0x38, 0x20}));
        try { KeyboardAuth.challengeCommand(new byte[3], new byte[16]); throw new AssertionError(); }
        catch (IllegalArgumentException expected) {}
        for (int code : new int[]{1, 2, 3, -1, 0, 7}) {
            Authority a = new Authority(); a.result = code;
            KeyboardAuth.Result expected = code == 1 ? KeyboardAuth.Result.ONLINE_VERIFIED
                    : code == 2 ? KeyboardAuth.Result.OFFLINE_VERIFIED_RECHECK
                    : code == 3 ? KeyboardAuth.Result.INTERNAL_ERROR : KeyboardAuth.Result.REJECTED;
            Transport t = new Transport(); check(run(t, a) == expected && t.calls == 2 && a.verified == 1);
        }
        for (int at : new int[]{1, 2}) {
            Transport t = new Transport(); t.failAt = at; Authority a = new Authority();
            check(run(t, a) == KeyboardAuth.Result.TRANSFER_ERROR && a.verified == 0);
        }
        for (int at : new int[]{1, 2, 3}) {
            Authority a = new Authority(); a.failAt = at;
            check(run(new Transport(), a) == KeyboardAuth.Result.AUTHORITY_UNAVAILABLE);
        }
        for (int size = 0; size < 33; ++size) {
            Transport t = new Transport(); t.init = Arrays.copyOf(t.init, size); Authority a = new Authority();
            check(run(t, a) == KeyboardAuth.Result.PROTOCOL_ERROR && a.calls == 0);
        }
        for (int size = 0; size < 23; ++size) {
            Transport t = new Transport(); t.token = Arrays.copyOf(t.token, size); Authority a = new Authority();
            check(run(t, a) == KeyboardAuth.Result.PROTOCOL_ERROR && a.verified == 0);
        }
        Transport padded = new Transport(); padded.init = Arrays.copyOf(padded.init, 64);
        padded.token = Arrays.copyOf(padded.token, 64);
        check(run(padded, new Authority()) == KeyboardAuth.Result.ONLINE_VERIFIED);
        for (int field : new int[]{4, 5, 8, 24, 32}) {
            Transport t = new Transport(); t.init[field] ^= 1; Authority a = new Authority();
            check(run(t, a) == KeyboardAuth.Result.PROTOCOL_ERROR && a.calls == 0);
        }
        Transport stale = new Transport(); stale.token = stale.init;
        check(run(stale, new Authority()) == KeyboardAuth.Result.PROTOCOL_ERROR);
        for (byte[] key : new byte[][]{null, new byte[0], new byte[3], new byte[5], new byte[]{9, 9, 9, 9}}) {
            Authority a = new Authority(); a.key = key; Transport t = new Transport();
            check(run(t, a) == (key != null && key.length == 0 ? KeyboardAuth.Result.REJECTED
                    : KeyboardAuth.Result.INTERNAL_ERROR));
            check(t.calls == 1 && a.verified == 0);
        }
        for (byte[] value : new byte[][]{null, new byte[0], new byte[15], new byte[17]}) {
            Authority a = new Authority(); a.challenge = value; Transport t = new Transport();
            check(run(t, a) == KeyboardAuth.Result.INTERNAL_ERROR && t.calls == 1 && a.verified == 0);
        }
        check(KeyboardAuth.verifyOnce(null, new Authority()) == KeyboardAuth.Result.AUTHORITY_UNAVAILABLE);
        check(!KeyboardAuth.validResponse(initReply(), 0x31, Integer.MAX_VALUE));
        check(!KeyboardAuth.validResponse(initReply(), 0x31, -7));
        Random random = new Random(0x32063ffc);
        for (int i = 0; i < 10000; ++i) {
            byte[] packet = new byte[random.nextInt(96)]; random.nextBytes(packet);
            KeyboardAuth.validResponse(packet, 0x31, 26);
            KeyboardAuth.validResponse(packet, 0x32, 16);
            KeyboardAuth.authCommand(packet);
        }
        System.out.println("PASS: golden requests, actual-length framing, checksum/command rejection, exact identity/token flow, offline/reject/error states, malformed replies");
    }
}
