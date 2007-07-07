/*
 * Very simple serial port class for Mac OS X and Windows XP
 * reference
 * http://www.easysw.com/~mike/serial/serial.html
 */

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#if defined(__MINGW32__)
#include <windows.h>
#else
#include <sys/ioctl.h>
#include <termios.h>
#endif

#include <ruby.h>

static VALUE mFunnel;
static VALUE cSerialPort;

struct serial_port
{
	int fd;
	char buffer[128];
#if defined(__MINGW32__)
	HANDLE fh;
#endif
};

static void
sp_mark(struct serial_port *sp)
{
	
}

static void
sp_free(struct serial_port *sp)
{
	close(sp->fd);
	free(sp);
}

static VALUE
sp_allocate(VALUE klass)
{
	struct serial_port *sp = malloc(sizeof(*sp));
	sp->fd = -1;
	return Data_Wrap_Struct(klass, sp_mark, sp_free, sp);
}

static VALUE
sp_initialize(VALUE self, VALUE port, VALUE baudrate)
{
#if defined(__MINGW32__)
	char *_port;
	DCB dcb;
	int _baudrate;
	struct serial_port *sp;
	COMMTIMEOUTS ctout;

	Data_Get_Struct(self, struct serial_port, sp);

	Check_SafeStr(port);
	_port = RSTRING(port)->ptr;

	sp->fd = open(_port, O_BINARY | O_RDWR);
	if (sp->fd == -1)
		rb_sys_fail(_port);
	sp->fh = (HANDLE) _get_osfhandle(sp->fd);
	if (SetupComm(sp->fh, 1024, 1024) == 0) {
		close(sp->fd);
		rb_raise(rb_eArgError, "not a serial port");
	}

	dcb.DCBlength = sizeof(dcb);
	if (GetCommState(sp->fh, &dcb) == 0) {
		close(sp->fd);
		rb_sys_fail("GetCommState");
	}
	dcb.fBinary = TRUE;
	dcb.fParity = FALSE;
	dcb.fOutxDsrFlow = FALSE;
	dcb.fDtrControl = DTR_CONTROL_DISABLE;
	dcb.fDsrSensitivity = FALSE;
	dcb.fTXContinueOnXoff = FALSE;
	dcb.fErrorChar = FALSE;
	dcb.fNull = FALSE;
	dcb.fAbortOnError = FALSE;
	dcb.XonChar = 17;
	dcb.XoffChar = 19;

	switch (FIX2INT(baudrate)) {
		case 9600:
		case 19200:
		case 38400:
		case 57600:
		case 115200:
		case 230400:
			_baudrate = FIX2INT(baudrate);
			break;
		default:
			rb_raise(rb_eArgError, "unsupported baud rate");
			break;
	}

	//set modem parameters
	dcb.BaudRate = FIX2INT(baudrate);
	dcb.ByteSize = 8;
	dcb.StopBits = ONESTOPBIT;
	dcb.Parity = NOPARITY;

	if (SetCommState(sp->fh, &dcb) == 0) {
		close(sp->fd);
		rb_sys_fail("SetCommState");
	}

	rb_fdopen(sp->fd, "rb+");

	if (GetCommTimeouts(sp->fh, &ctout) == 0) {
		rb_sys_fail("GetCommTimeouts");
	}

	ctout.ReadIntervalTimeout = MAXDWORD;
	ctout.ReadTotalTimeoutMultiplier = MAXDWORD;
	ctout.ReadTotalTimeoutConstant = MAXDWORD - 1;

	if (SetCommTimeouts(sp->fh, &ctout) == 0) {
		rb_sys_fail("SetCommTimeouts");
	}

	return self;
#else
	struct termios options;
	int _baudrate;
	struct serial_port *sp;

	Data_Get_Struct(self, struct serial_port, sp);

	sp->fd = open(RSTRING(port)->ptr, O_RDWR | O_NOCTTY | O_NDELAY);
	if (sp->fd == -1) {
		rb_sys_fail(RSTRING(port)->ptr);
	}

	if (tcgetattr(sp->fd, &options) == -1) {
		rb_sys_fail("tcgetattr");
	}

	switch (FIX2INT(baudrate)) {
		case 9600: _baudrate = B9600; break;
		case 19200: _baudrate = B19200; break;
		case 38400: _baudrate = B38400; break;
		case 57600: _baudrate = B57600; break;
		case 115200: _baudrate = B115200; break;
		case 230400: _baudrate = B230400; break;
		default:
			rb_raise(rb_eArgError, "unsupported baud rate"); break;
	}

	// set basic parameters
	options.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG);
	options.c_cflag |= (CLOCAL | CREAD);

	// set baud rate
	cfsetispeed(&options, _baudrate);
	cfsetospeed(&options, _baudrate);

	// set data bits to 8 bit
	options.c_cflag &= ~CSIZE;
	options.c_cflag |= CS8;

	// set stop bits to 1 bit
	options.c_cflag &= ~CSTOPB;

	// set parity to none
	options.c_cflag &= ~PARENB;

#ifdef CNEW_RTSCTS
	// disable hardware flow control
	options.c_cflag &= ~CNEW_RTSCTS;
#endif

	if (tcsetattr(sp->fd, TCSANOW, &options) == -1) {
		rb_sys_fail("tcsetattr");
	}

	return self;
#endif
}

static VALUE
sp_write(VALUE self, VALUE data)
{
	int written_bytes;
	struct serial_port *sp;

	Data_Get_Struct(self, struct serial_port, sp);
	written_bytes = write(sp->fd, RSTRING(data)->ptr, RSTRING(data)->len);
	return INT2FIX(written_bytes);
}

static VALUE
sp_read(VALUE self, VALUE bytes)
{
	int read_bytes;
	struct serial_port *sp;

	Data_Get_Struct(self, struct serial_port, sp);
	read_bytes = read(sp->fd, sp->buffer, FIX2INT(bytes));
	return rb_str_new(sp->buffer, read_bytes);
}

static VALUE
sp_bytes_available(VALUE self)
{
#if defined(__MINGW32__)
	int bytes;
	struct serial_port *sp;
	DWORD errors;
	COMSTAT stat;
	
	Data_Get_Struct(self, struct serial_port, sp);

	if (!ClearCommError(sp->fh, &errors, &stat)) {
		rb_sys_fail("ClearCommError");
		return 0;
	}

	return INT2FIX(stat.cbInQue);
#else
	int bytes;
	struct serial_port *sp;

	Data_Get_Struct(self, struct serial_port, sp);
	ioctl(sp->fd, FIONREAD, &bytes);
	return INT2FIX(bytes);
#endif
}

void Init_serial_port()
{
	mFunnel = rb_define_module("Funnel");
	cSerialPort = rb_define_class_under(mFunnel, "SerialPort", rb_cObject);

	rb_define_alloc_func(cSerialPort, sp_allocate);
	rb_define_method(cSerialPort, "initialize", sp_initialize, 2);
	rb_define_method(cSerialPort, "write", sp_write, 1);
	rb_define_method(cSerialPort, "read", sp_read, 1);
	rb_define_method(cSerialPort, "bytes_available", sp_bytes_available, 0);
}
