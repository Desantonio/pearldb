# PearlDB 🐚

**PearlDB** is a lightweight SQL-like embedded database engine written entirely in [Perl](https://www.perl.org/). It supports a subset of SQL commands such as:

- `CREATE DATABASE`, `DROP DATABASE`
- `USE`
- `CREATE TABLE`, `DROP TABLE`
- `INSERT INTO`, `SELECT`, `UPDATE`, `DELETE`
- `SHOW DATABASES`, `SHOW TABLES`
- `EXIT`

PearlDB is ideal for small-scale apps, scripting environments, educational tools, or prototyping SQL engines.

---

## 🚀 Features

- Written in pure Perl — no external dependencies
- Simple file-based storage using structured text
- In-memory query parsing and command execution
- CLI interface with REPL-like behavior
- Test suite included

---

## 📦 Installation

### 🔧 Option 1: Clone and Run
```bash
git clone https://github.com/vatsalgayakwad/pearldb.git
cd pearldb
perl ./bin/pearldb

### 🍺 Install via Homebrew

```bash
# Tap the repository
brew tap Desantonio/pearldb

# Install pearldb
brew install pearldb

# Run pearldb
pearldb
