// SPDX-License-Identifier: Apache-2.0
package org.pixelos.nabu.usb;

import android.os.IBinder;
import android.os.Parcel;
import android.os.RemoteException;
import java.io.IOException;

/** Exact stock AIDL wire protocol. Caller must explicitly bind the trusted stock component. */
public final class StockAuthAuthority implements KeyboardAuth.Authority {
    public static final String PACKAGE = "com.xiaomi.devauth";
    public static final String SERVICE = "com.xiaomi.devauth.MiDevAuthService";
    private static final String DESCRIPTOR = "com.xiaomi.devauth.IMiDevAuthInterface";
    private final IBinder binder;
    public StockAuthAuthority(IBinder binder) throws IOException {
        try {
            if (binder == null || !DESCRIPTOR.equals(binder.getInterfaceDescriptor()))
                throw new IOException("Wrong device authentication service");
        } catch (RemoteException e) { throw new IOException("Authentication service disconnected", e); }
        this.binder = binder;
    }
    private void transact(int code, Parcel request, Parcel reply) throws IOException {
        try {
            if (!binder.transact(code, request, reply, 0))
                throw new IOException("Unsupported authentication transaction");
            reply.readException();
        } catch (RemoteException | RuntimeException e) {
            throw new IOException("Authentication transaction failed", e);
        }
    }
    private static byte[] readBytes(Parcel reply, int maximum) throws IOException {
        try {
            int position = reply.dataPosition();
            int size = reply.readInt();
            if (size < -1 || size > maximum) throw new IOException("Invalid authentication reply length");
            reply.setDataPosition(position);
            byte[] value = reply.createByteArray();
            if (reply.dataAvail() != 0) throw new IOException("Unexpected authentication reply data");
            return value;
        } catch (RuntimeException e) { throw new IOException("Malformed authentication reply", e); }
    }
    private static void require(byte[] value, int size) {
        if (value == null || value.length != size) throw new IllegalArgumentException("Invalid authentication argument length");
    }
    @Override public byte[] getChallenge(int size) throws IOException {
        if (size != 16) throw new IllegalArgumentException("Expected 16-byte challenge");
        Parcel request = Parcel.obtain(), reply = Parcel.obtain();
        try {
            request.writeInterfaceToken(DESCRIPTOR); request.writeInt(size);
            transact(1, request, reply); return readBytes(reply, 16);
        } finally { reply.recycle(); request.recycle(); }
    }
    @Override public byte[] chooseKey(byte[] uid, byte[] first, byte[] second) throws IOException {
        require(uid, 16); require(first, 4); require(second, 4);
        Parcel request = Parcel.obtain(), reply = Parcel.obtain();
        try {
            request.writeInterfaceToken(DESCRIPTOR);
            request.writeByteArray(uid); request.writeByteArray(first); request.writeByteArray(second);
            transact(2, request, reply); return readBytes(reply, 4);
        } finally { reply.recycle(); request.recycle(); }
    }
    @Override public int verify(int type, byte[] uid, byte[] key, byte[] challenge, byte[] token)
            throws IOException {
        if (type != 1) throw new IllegalArgumentException("Only keyboard type 1 is supported");
        require(uid, 16); require(key, 4); require(challenge, 16); require(token, 16);
        Parcel request = Parcel.obtain(), reply = Parcel.obtain();
        try {
            request.writeInterfaceToken(DESCRIPTOR); request.writeInt(type);
            request.writeByteArray(uid); request.writeByteArray(key);
            request.writeByteArray(challenge); request.writeByteArray(token);
            transact(3, request, reply);
            int result = reply.readInt();
            if (reply.dataAvail() != 0) throw new IOException("Unexpected verification reply data");
            return result;
        } catch (RuntimeException e) { throw new IOException("Malformed verification reply", e); }
        finally { reply.recycle(); request.recycle(); }
    }
}
