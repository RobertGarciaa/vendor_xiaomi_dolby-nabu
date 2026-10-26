// SPDX-License-Identifier: Apache-2.0
package org.pixelos.nabu.usb;

import android.hardware.usb.UsbConstants;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbDeviceConnection;
import android.hardware.usb.UsbEndpoint;
import android.hardware.usb.UsbInterface;
import android.hardware.usb.UsbManager;
import android.os.SystemClock;
import java.io.IOException;
import java.util.Arrays;

/** Conservative adapter: never force-detach a HID driver or select an ambiguous interface. */
public final class UsbAuthTransport implements KeyboardAuth.Transport, AutoCloseable {
    private final UsbDeviceConnection connection;
    private final UsbInterface iface;
    private final UsbEndpoint in, out;
    private boolean closed;
    private UsbAuthTransport(UsbDeviceConnection connection, UsbInterface iface,
            UsbEndpoint in, UsbEndpoint out) {
        this.connection = connection; this.iface = iface; this.in = in; this.out = out;
    }
    public static UsbAuthTransport open(UsbManager manager, UsbDevice device) throws IOException {
        if (manager == null || device == null || device.getVendorId() != 0x3206
                || device.getProductId() != 0x3ffc || !manager.hasPermission(device))
            throw new IOException("Keyboard unavailable or USB permission missing");
        // No setConfiguration/setInterface calls; changing them can disrupt HID input.
        if (device.getConfigurationCount() != 1) throw new IOException("Unverified USB configuration");
        UsbInterface selected = null;
        UsbEndpoint selectedIn = null, selectedOut = null;
        for (int i = 0; i < device.getInterfaceCount(); ++i) {
            UsbInterface candidate = device.getInterface(i);
            if (candidate.getInterfaceClass() != UsbConstants.USB_CLASS_VENDOR_SPEC
                    || candidate.getAlternateSetting() != 0) continue;
            UsbEndpoint input = null, output = null;
            boolean ambiguous = false;
            for (int j = 0; j < candidate.getEndpointCount(); ++j) {
                UsbEndpoint ep = candidate.getEndpoint(j);
                if (ep.getType() != UsbConstants.USB_ENDPOINT_XFER_BULK
                        || ep.getMaxPacketSize() < 64) continue;
                if (ep.getDirection() == UsbConstants.USB_DIR_IN) {
                    if (input != null) ambiguous = true;
                    input = ep;
                } else {
                    if (output != null) ambiguous = true;
                    output = ep;
                }
            }
            if (!ambiguous && input != null && output != null) {
                if (selected != null) throw new IOException("Ambiguous vendor command interface");
                selected = candidate; selectedIn = input; selectedOut = output;
            }
        }
        if (selected == null) throw new IOException("No verified non-HID bulk command interface");
        UsbDeviceConnection connection = manager.openDevice(device);
        if (connection == null) throw new IOException("Cannot open keyboard");
        try {
            if (!connection.claimInterface(selected, false))
                throw new IOException("Command interface is already claimed");
        } catch (IOException | RuntimeException e) { connection.close(); throw e; }
        return new UsbAuthTransport(connection, selected, selectedIn, selectedOut);
    }
    @Override public synchronized byte[] exchange(byte[] command) throws IOException {
        if (closed) throw new IOException("Keyboard transport closed");
        if (!KeyboardAuth.authCommand(command)) throw new IOException("Only authentication reports allowed");
        byte[] report = Arrays.copyOf(command, 64);
        try {
            // Stock sends a zero-padded 64-byte report; a short transfer is an error.
            if (connection.bulkTransfer(out, report, report.length, 250) != report.length)
                throw new IOException("Incomplete authentication request");
        } finally { Arrays.fill(report, (byte) 0); }
        int commandId = command[4] & 255;
        int payloadSize = commandId == 0x31 ? 26 : 16;
        long deadline = SystemClock.elapsedRealtime() + 1000;
        byte[] buffer = new byte[64];
        try {
            for (int attempt = 0; attempt < 8; ++attempt) {
                int timeout = (int) Math.min(250, deadline - SystemClock.elapsedRealtime());
                if (timeout <= 0) break;
                int received = connection.bulkTransfer(in, buffer, buffer.length, timeout);
                if (received < 0 || received > buffer.length)
                    throw new IOException("Authentication response transfer failed");
                byte[] response = Arrays.copyOf(buffer, received);
                if (KeyboardAuth.validResponse(response, commandId, payloadSize)) return response;
                Arrays.fill(response, (byte) 0);
            }
            throw new IOException("No matching authentication response within deadline");
        } finally { Arrays.fill(buffer, (byte) 0); }
    }
    @Override public synchronized void close() {
        if (!closed) {
            closed = true;
            try { connection.releaseInterface(iface); } finally { connection.close(); }
        }
    }
}
