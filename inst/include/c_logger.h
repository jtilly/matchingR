#ifndef LOGGER_H
#define LOGGER_H

#include<matchingR.h>

class c_log_message {
    public:
    c_log_message(const char *header) {
        Rcout << header;
    }

    c_log_message(bool result) {
        Rcout << "[";
        if (result) {
            Rcout << "SUCCESS";

        } else {
            Rcout << "FAILURE";
        }

        Rcout << "] ";
    }

    ~c_log_message() {
        Rcout << "\n";
    }

    template<typename T>
    c_log_message &operator<<(const T &t) {
        Rcout << t;
        return *this;
    }
};

class c_logger {
    public:
    c_log_message error() {
        return c_log_message("[ERROR] ");
    }

    c_log_message info() {
        return c_log_message("[INFO] ");
    }

    c_log_message warning() {
        return c_log_message("[WARNING ]");
    }

    c_log_message test(bool result) {
        return c_log_message(result);
    }

    c_log_message breakLine() {
        return c_log_message("-----------------------------------------------------------");
    }
};

c_logger &log();

#endif
