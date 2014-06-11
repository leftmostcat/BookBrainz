--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: bookbrainz; Type: SCHEMA; Schema: -; Owner: bookbrainz
--

CREATE SCHEMA bookbrainz;


ALTER SCHEMA bookbrainz OWNER TO bookbrainz;

SET search_path = bookbrainz, pg_catalog;

--
-- Name: comment; Type: DOMAIN; Schema: bookbrainz; Owner: bookbrainz
--

CREATE DOMAIN comment AS text;

--
-- Name: locale; Type: DOMAIN; Schema: bookbrainz; Owner: bookbrainz
--

CREATE DOMAIN locale AS character varying(30)
	CONSTRAINT locale_check CHECK ((((VALUE)::text ~ '^[a-zA-Z_]+$'::text) OR (VALUE IS NULL)));


ALTER DOMAIN bookbrainz.locale OWNER TO bookbrainz;

--
-- Name: natural_integer; Type: DOMAIN; Schema: bookbrainz; Owner: bookbrainz
--

CREATE DOMAIN natural_integer AS integer
	CONSTRAINT natural_integer_check CHECK ((VALUE >= 0));


ALTER DOMAIN bookbrainz.natural_integer OWNER TO bookbrainz;

--
-- Name: single_line; Type: DOMAIN; Schema: bookbrainz; Owner: bookbrainz
--

CREATE DOMAIN single_line AS text;


ALTER DOMAIN bookbrainz.single_line OWNER TO bookbrainz;

--
-- Name: presentational_text; Type: DOMAIN; Schema: bookbrainz; Owner: bookbrainz
--

CREATE DOMAIN presentational_text AS single_line;


ALTER DOMAIN bookbrainz.presentational_text OWNER TO bookbrainz;

--
-- Name: non_empty_presentational_text; Type: DOMAIN; Schema: bookbrainz; Owner: bookbrainz
--

CREATE DOMAIN non_empty_presentational_text AS presentational_text;


ALTER DOMAIN bookbrainz.non_empty_presentational_text OWNER TO bookbrainz;

--
-- Name: positive_integer; Type: DOMAIN; Schema: bookbrainz; Owner: bookbrainz
--

CREATE DOMAIN positive_integer AS integer
	CONSTRAINT positive_integer_check CHECK ((VALUE > 0));


ALTER DOMAIN bookbrainz.positive_integer OWNER TO bookbrainz;

--
-- Name: find_or_insert_creator_data(text, text, text, integer, integer, integer, integer, integer, integer, boolean, integer, integer, integer); Type: FUNCTION; Schema: bookbrainz; Owner: bookbrainz
--

CREATE FUNCTION find_or_insert_creator_data(in_name text, in_sort_name text, in_comment text, in_b_year integer, in_b_month integer, in_b_day integer, in_e_year integer, in_e_month integer, in_e_day integer, in_ended boolean, in_gender_id integer, in_type_id integer, in_country_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    found_id INT;
  BEGIN
    SELECT creator_data_id INTO found_id
    FROM creator_data
    WHERE name = in_name AND sort_name = in_sort_name AND comment = in_comment AND
      begin_date_year IS NOT DISTINCT FROM in_b_year AND
      begin_date_month IS NOT DISTINCT FROM in_b_month AND
      begin_date_day IS NOT DISTINCT FROM in_b_day AND
      end_date_year IS NOT DISTINCT FROM in_b_year AND
      end_date_month IS NOT DISTINCT FROM in_b_month AND
      end_date_day IS NOT DISTINCT FROM in_b_day AND
      ended = in_ended AND
      gender_id IS NOT DISTINCT FROM in_gender_id AND
      creator_type_id IS NOT DISTINCT FROM in_type_id AND
      country_id IS NOT DISTINCT FROM in_country_id;

    IF FOUND
    THEN
      RETURN found_id;
    ELSE
      INSERT INTO creator_data (name, sort_name, comment,
        begin_date_year, begin_date_month, begin_date_day,
        end_date_year, end_date_month, end_date_day,
        ended, gender_id, creator_type_id, country_id)
      VALUES (in_name, in_sort_name, in_comment,
        in_b_year, in_b_month, in_b_day,
        in_e_year, in_e_month, in_e_day,
        in_ended, in_gender_id, in_type_id, in_country_id)
      RETURNING creator_data_id INTO found_id;
      RETURN found_id;
    END IF;
  END;
$$;


ALTER FUNCTION bookbrainz.find_or_insert_creator_data(in_name text, in_sort_name text, in_comment text, in_b_year integer, in_b_month integer, in_b_day integer, in_e_year integer, in_e_month integer, in_e_day integer, in_ended boolean, in_gender_id integer, in_type_id integer, in_country_id integer) OWNER TO bookbrainz;

--
-- Name: find_or_insert_publisher_data(text, text, text, integer, integer, integer, integer, integer, integer, boolean, integer, integer); Type: FUNCTION; Schema: bookbrainz; Owner: bookbrainz
--

CREATE FUNCTION find_or_insert_publisher_data(in_name text, in_sort_name text, in_comment text, in_b_year integer, in_b_month integer, in_b_day integer, in_e_year integer, in_e_month integer, in_e_day integer, in_ended boolean, in_type_id integer, in_country integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    found_id INT;
  BEGIN
    SELECT publisher_data_id INTO found_id
    FROM publisher_data
    WHERE name = in_name AND sort_name = in_sort_name AND comment = in_comment AND
      begin_date_year IS NOT DISTINCT FROM in_b_year AND
      begin_date_month IS NOT DISTINCT FROM in_b_month AND
      begin_date_day IS NOT DISTINCT FROM in_b_day AND
      end_date_year IS NOT DISTINCT FROM in_b_year AND
      end_date_month IS NOT DISTINCT FROM in_b_month AND
      end_date_day IS NOT DISTINCT FROM in_b_day AND
      ended = in_ended AND
      publisher_type_id IS NOT DISTINCT FROM in_type_id AND
      country_id IS NOT DISTINCT FROM in_country;

    IF FOUND
    THEN
      RETURN found_id;
    ELSE
      INSERT INTO publisher_data (name, sort_name, comment,
        begin_date_year, begin_date_month, begin_date_day,
        end_date_year, end_date_month, end_date_day,
        ended, publisher_type_id, country_id)
      VALUES (in_name, in_sort_name, in_comment,
        in_b_year, in_b_month, in_b_day,
        in_e_year, in_e_month, in_e_day,
        in_ended, in_type_id, in_country)
      RETURNING publisher_data_id INTO found_id;
      RETURN found_id;
    END IF;
  END;
$$;


ALTER FUNCTION bookbrainz.find_or_insert_publisher_data(in_name text, in_sort_name text, in_comment text, in_b_year integer, in_b_month integer, in_b_day integer, in_e_year integer, in_e_month integer, in_e_day integer, in_ended boolean, in_type_id integer, in_country integer) OWNER TO bookbrainz;

--
-- Name: find_or_insert_edition_data(text, text, integer, integer, integer, integer, integer, integer, integer, integer, text); Type: FUNCTION; Schema: bookbrainz; Owner: bookbrainz
--

CREATE FUNCTION find_or_insert_edition_data(in_name text, in_comment text, in_ac integer, in_date_year integer, in_date_month integer, in_date_day integer, in_country_id integer, in_script_id integer, in_language_id integer, in_status_id integer, in_barcode text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    found_id INT;
  BEGIN
    SELECT edition_data_id INTO found_id
    FROM edition_data
    WHERE name = in_name AND
      comment = in_comment AND
      creator_credit_id = in_ac AND
      date_year IS NOT DISTINCT FROM in_date_year AND
      date_month IS NOT DISTINCT FROM in_date_month AND
      date_day IS NOT DISTINCT FROM in_date_day AND
      country_id IS NOT DISTINCT FROM in_country_id AND
      script_id IS NOT DISTINCT FROM in_script_id AND
      language_id IS NOT DISTINCT FROM in_language_id AND
      edition_status_id IS NOT DISTINCT FROM in_status_id AND
      barcode IS NOT DISTINCT FROM in_barcode;

    IF FOUND
    THEN
      RETURN found_id;
    ELSE
      INSERT INTO edition_data (name, comment, creator_credit_id, date_year,
        date_month, date_day, country_id, script_id, language_id,
        edition_status_id, barcode)
      VALUES (in_name, in_comment, in_ac, in_date_year, in_date_month,
        in_date_day, in_country_id, in_script_id, in_language_id,
        in_status_id, in_barcode)
      RETURNING edition_data_id INTO found_id;
      RETURN found_id;
    END IF;
  END;
$$;


ALTER FUNCTION bookbrainz.find_or_insert_edition_data(in_name text, in_comment text, in_ac integer, in_date_year integer, in_date_month integer, in_date_day integer, in_country_id integer, in_script_id integer, in_language_id integer, in_status_id integer, in_barcode text) OWNER TO bookbrainz;

--
-- Name: find_or_insert_book_data(text, text, integer, integer); Type: FUNCTION; Schema: bookbrainz; Owner: bookbrainz
--

CREATE FUNCTION find_or_insert_book_data(in_name text, in_comment text, in_creator_credit_id integer, in_p_type_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    found_id INT;
  BEGIN
    SELECT book_data_id INTO found_id
    FROM book_data
    WHERE name = in_name AND
      comment = in_comment AND
      creator_credit_id = in_creator_credit_id AND
      book_type_id IS NOT DISTINCT FROM in_p_type_id;

    IF FOUND
    THEN
      RETURN found_id;
    ELSE
      INSERT INTO book_data (name, comment, creator_credit_id,
        book_type_id)
      VALUES (in_name, in_comment, in_creator_credit_id, in_p_type_id)
      RETURNING book_data_id INTO found_id;
      RETURN found_id;
    END IF;
  END;
$$;


ALTER FUNCTION bookbrainz.find_or_insert_book_data(in_name text, in_comment text, in_creator_credit_id integer, in_p_type_id integer) OWNER TO bookbrainz;

--
-- Name: find_or_insert_book_tree(integer); Type: FUNCTION; Schema: bookbrainz; Owner: bookbrainz
--

CREATE FUNCTION find_or_insert_book_tree(in_data_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    found_id INT;
  BEGIN
    SELECT book_tree_id INTO found_id
    FROM book_tree WHERE book_data_id = in_data_id;

    IF FOUND
    THEN
      RETURN found_id;
    ELSE
      INSERT INTO book_tree (book_data_id)
      VALUES (in_data_id)
      RETURNING book_tree_id INTO found_id;
      RETURN found_id;
    END IF;
  END;
$$;


ALTER FUNCTION bookbrainz.find_or_insert_book_tree(in_data_id integer) OWNER TO bookbrainz;

--
-- Name: find_or_insert_edition_tree(integer); Type: FUNCTION; Schema: bookbrainz; Owner: bookbrainz
--

CREATE FUNCTION find_or_insert_edition_tree(in_data_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    found_id INT;
  BEGIN
    SELECT edition_tree_id INTO found_id
    FROM edition_tree WHERE edition_data_id = in_data_id;

    IF FOUND
    THEN
      RETURN found_id;
    ELSE
      INSERT INTO edition_tree (edition_data_id)
      VALUES (in_data_id)
      RETURNING edition_tree_id INTO found_id;
      RETURN found_id;
    END IF;
  END;
$$;


ALTER FUNCTION bookbrainz.find_or_insert_edition_tree(in_data_id integer) OWNER TO bookbrainz;

--
-- Name: find_or_insert_edition_tree(integer, uuid); Type: FUNCTION; Schema: bookbrainz; Owner: bookbrainz
--

CREATE FUNCTION find_or_insert_edition_tree(in_data_id integer, in_rg uuid) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    found_id INT;
  BEGIN
    SELECT edition_tree_id INTO found_id
    FROM edition_tree WHERE edition_data_id = in_data_id AND book_id = in_rg;

    IF FOUND
    THEN
      RETURN found_id;
    ELSE
      INSERT INTO edition_tree (edition_data_id, book_id)
      VALUES (in_data_id, in_rg)
      RETURNING edition_tree_id INTO found_id;
      RETURN found_id;
    END IF;
  END;
$$;


ALTER FUNCTION bookbrainz.find_or_insert_edition_tree(in_data_id integer, in_rg uuid) OWNER TO bookbrainz;

--
-- Name: find_or_insert_url_data(text); Type: FUNCTION; Schema: bookbrainz; Owner: bookbrainz
--

CREATE FUNCTION find_or_insert_url_data(in_url text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    found_id INT;
  BEGIN
    SELECT url_data_id INTO found_id
    FROM url_data
    WHERE url = in_url;

    IF FOUND
    THEN
      RETURN found_id;
    ELSE
      INSERT INTO url_data (url)
      VALUES (in_url)
      RETURNING url_data_id INTO found_id;
      RETURN found_id;
    END IF;
  END;
$$;


ALTER FUNCTION bookbrainz.find_or_insert_url_data(in_url text) OWNER TO bookbrainz;

--
-- Name: find_or_insert_work_data(text, text, integer, integer); Type: FUNCTION; Schema: bookbrainz; Owner: bookbrainz
--

CREATE FUNCTION find_or_insert_work_data(in_name text, in_comment text, in_type_id integer, in_language_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    found_id INT;
  BEGIN
    SELECT work_data_id INTO found_id
    FROM work_data
    WHERE name = in_name AND comment = in_comment AND
      work_type_id IS NOT DISTINCT FROM in_type_id AND
      language_id IS NOT DISTINCT FROM in_language_id;

    IF FOUND
    THEN
      RETURN found_id;
    ELSE
      INSERT INTO work_data (name, comment, work_type_id, language_id)
      VALUES (in_name, in_comment, in_type_id, in_language_id)
      RETURNING work_data_id INTO found_id;
      RETURN found_id;
    END IF;
  END;
$$;


ALTER FUNCTION bookbrainz.find_or_insert_work_data(in_name text, in_comment text, in_type_id integer, in_language_id integer) OWNER TO bookbrainz;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: creator; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE creator (
    creator_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    master_revision_id integer NOT NULL,
    merged_into uuid
);


ALTER TABLE bookbrainz.creator OWNER TO bookbrainz;

--
-- Name: creator_credit; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE creator_credit (
    creator_credit_id integer NOT NULL,
    pre_phrase presentational_text DEFAULT ''::text NOT NULL
);


ALTER TABLE bookbrainz.creator_credit OWNER TO bookbrainz;

--
-- Name: creator_credit_creator_credit_id_seq; Type: SEQUENCE; Schema: bookbrainz; Owner: bookbrainz
--

CREATE SEQUENCE creator_credit_creator_credit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bookbrainz.creator_credit_creator_credit_id_seq OWNER TO bookbrainz;

--
-- Name: creator_credit_creator_credit_id_seq; Type: SEQUENCE OWNED BY; Schema: bookbrainz; Owner: bookbrainz
--

ALTER SEQUENCE creator_credit_creator_credit_id_seq OWNED BY creator_credit.creator_credit_id;


--
-- Name: creator_credit_name; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE creator_credit_name (
    creator_credit_id integer NOT NULL,
    "position" natural_integer NOT NULL,
    creator_id uuid NOT NULL,
    name non_empty_presentational_text NOT NULL,
    join_phrase single_line DEFAULT ''::text NOT NULL
);


ALTER TABLE bookbrainz.creator_credit_name OWNER TO bookbrainz;

--
-- Name: creator_data; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE creator_data (
    creator_data_id integer NOT NULL,
    name non_empty_presentational_text NOT NULL,
    sort_name non_empty_presentational_text NOT NULL,
    begin_date_year smallint,
    begin_date_month smallint,
    begin_date_day smallint,
    end_date_year smallint,
    end_date_month smallint,
    end_date_day smallint,
    creator_type_id integer,
    country_id integer,
    gender_id integer,
    comment presentational_text DEFAULT ''::text NOT NULL,
    ended boolean DEFAULT false NOT NULL
);


ALTER TABLE bookbrainz.creator_data OWNER TO bookbrainz;

--
-- Name: creator_data_creator_data_id_seq; Type: SEQUENCE; Schema: bookbrainz; Owner: bookbrainz
--

CREATE SEQUENCE creator_data_creator_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bookbrainz.creator_data_creator_data_id_seq OWNER TO bookbrainz;

--
-- Name: creator_data_creator_data_id_seq; Type: SEQUENCE OWNED BY; Schema: bookbrainz; Owner: bookbrainz
--

ALTER SEQUENCE creator_data_creator_data_id_seq OWNED BY creator_data.creator_data_id;

--
-- Name: creator_revision; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE creator_revision (
    revision_id integer NOT NULL,
    creator_id uuid NOT NULL,
    creator_tree_id integer NOT NULL
);


ALTER TABLE bookbrainz.creator_revision OWNER TO bookbrainz;

--
-- Name: creator_tree; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE creator_tree (
    creator_tree_id integer NOT NULL,
    creator_data_id integer NOT NULL,
    annotation text
);


ALTER TABLE bookbrainz.creator_tree OWNER TO bookbrainz;

--
-- Name: creator_tree_id_seq; Type: SEQUENCE; Schema: bookbrainz; Owner: bookbrainz
--

CREATE SEQUENCE creator_tree_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bookbrainz.creator_tree_id_seq OWNER TO bookbrainz;

--
-- Name: creator_tree_id_seq; Type: SEQUENCE OWNED BY; Schema: bookbrainz; Owner: bookbrainz
--

ALTER SEQUENCE creator_tree_id_seq OWNED BY creator_tree.creator_tree_id;


--
-- Name: creator_type; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE creator_type (
    id integer NOT NULL,
    name presentational_text NOT NULL
);


ALTER TABLE bookbrainz.creator_type OWNER TO bookbrainz;

--
-- Name: creator_type_id_seq; Type: SEQUENCE; Schema: bookbrainz; Owner: bookbrainz
--

CREATE SEQUENCE creator_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bookbrainz.creator_type_id_seq OWNER TO bookbrainz;

--
-- Name: creator_type_id_seq; Type: SEQUENCE OWNED BY; Schema: bookbrainz; Owner: bookbrainz
--

ALTER SEQUENCE creator_type_id_seq OWNED BY creator_type.id;

--
-- Name: country; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE country (
    id integer NOT NULL,
    iso_code character varying(2) NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE bookbrainz.country OWNER TO bookbrainz;

--
-- Name: country_id_seq; Type: SEQUENCE; Schema: bookbrainz; Owner: bookbrainz
--

CREATE SEQUENCE country_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bookbrainz.country_id_seq OWNER TO bookbrainz;

--
-- Name: country_id_seq; Type: SEQUENCE OWNED BY; Schema: bookbrainz; Owner: bookbrainz
--

ALTER SEQUENCE country_id_seq OWNED BY country.id;


--
-- Name: edit; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE edit (
    edit_id integer NOT NULL,
    status smallint
);


ALTER TABLE bookbrainz.edit OWNER TO bookbrainz;

--
-- Name: edit_creator; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE edit_creator (
    edit_id integer NOT NULL,
    revision_id integer NOT NULL
);


ALTER TABLE bookbrainz.edit_creator OWNER TO bookbrainz;

--
-- Name: edit_edit_id_seq; Type: SEQUENCE; Schema: bookbrainz; Owner: bookbrainz
--

CREATE SEQUENCE edit_edit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bookbrainz.edit_edit_id_seq OWNER TO bookbrainz;

--
-- Name: edit_edit_id_seq; Type: SEQUENCE OWNED BY; Schema: bookbrainz; Owner: bookbrainz
--

ALTER SEQUENCE edit_edit_id_seq OWNED BY edit.edit_id;


--
-- Name: edit_publisher; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE edit_publisher (
    edit_id integer NOT NULL,
    revision_id integer NOT NULL
);


ALTER TABLE bookbrainz.edit_publisher OWNER TO bookbrainz;

--
-- Name: edit_note; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE edit_note (
    editor_id integer NOT NULL,
    edit_id integer NOT NULL,
    text text,
    edit_note_id integer NOT NULL
);


ALTER TABLE bookbrainz.edit_note OWNER TO bookbrainz;

--
-- Name: edit_note_edit_note_id_seq; Type: SEQUENCE; Schema: bookbrainz; Owner: bookbrainz
--

CREATE SEQUENCE edit_note_edit_note_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bookbrainz.edit_note_edit_note_id_seq OWNER TO bookbrainz;

--
-- Name: edit_note_edit_note_id_seq; Type: SEQUENCE OWNED BY; Schema: bookbrainz; Owner: bookbrainz
--

ALTER SEQUENCE edit_note_edit_note_id_seq OWNED BY edit_note.edit_note_id;

--
-- Name: edit_edition; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE edit_edition (
    edit_id integer NOT NULL,
    revision_id integer NOT NULL
);


ALTER TABLE bookbrainz.edit_edition OWNER TO bookbrainz;

--
-- Name: edit_book; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE edit_book (
    edit_id integer NOT NULL,
    revision_id integer NOT NULL
);


ALTER TABLE bookbrainz.edit_book OWNER TO bookbrainz;

--
-- Name: edit_url; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE edit_url (
    edit_id integer NOT NULL,
    revision_id integer NOT NULL
);


ALTER TABLE bookbrainz.edit_url OWNER TO bookbrainz;

--
-- Name: edit_work; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE edit_work (
    edit_id integer NOT NULL,
    revision_id integer NOT NULL
);


ALTER TABLE bookbrainz.edit_work OWNER TO bookbrainz;

--
-- Name: editor; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE editor (
    id integer NOT NULL,
    name character varying(64) NOT NULL,
    privs integer DEFAULT 0,
    email character varying(64) DEFAULT NULL::character varying,
    website character varying(255) DEFAULT NULL::character varying,
    bio text,
    member_since timestamp with time zone DEFAULT now(),
    email_confirm_date timestamp with time zone,
    last_login_date timestamp with time zone,
    edits_accepted integer DEFAULT 0,
    edits_rejected integer DEFAULT 0,
    auto_edits_accepted integer DEFAULT 0,
    edits_failed integer DEFAULT 0,
    last_updated timestamp with time zone DEFAULT now(),
    birth_date date,
    gender integer,
    country integer
);


ALTER TABLE bookbrainz.editor OWNER TO bookbrainz;

--
-- Name: editor_id_seq; Type: SEQUENCE; Schema: bookbrainz; Owner: bookbrainz
--

CREATE SEQUENCE editor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bookbrainz.editor_id_seq OWNER TO bookbrainz;

--
-- Name: editor_id_seq; Type: SEQUENCE OWNED BY; Schema: bookbrainz; Owner: bookbrainz
--

ALTER SEQUENCE editor_id_seq OWNED BY editor.id;


--
-- Name: editor_preference; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE editor_preference (
    id integer NOT NULL,
    editor integer NOT NULL,
    name character varying(50) NOT NULL,
    value character varying(100) NOT NULL
);


ALTER TABLE bookbrainz.editor_preference OWNER TO bookbrainz;

--
-- Name: editor_preference_id_seq; Type: SEQUENCE; Schema: bookbrainz; Owner: bookbrainz
--

CREATE SEQUENCE editor_preference_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bookbrainz.editor_preference_id_seq OWNER TO bookbrainz;

--
-- Name: editor_preference_id_seq; Type: SEQUENCE OWNED BY; Schema: bookbrainz; Owner: bookbrainz
--

ALTER SEQUENCE editor_preference_id_seq OWNED BY editor_preference.id;


--
-- Name: gender; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE gender (
    id integer NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE bookbrainz.gender OWNER TO bookbrainz;

--
-- Name: gender_id_seq; Type: SEQUENCE; Schema: bookbrainz; Owner: bookbrainz
--

CREATE SEQUENCE gender_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bookbrainz.gender_id_seq OWNER TO bookbrainz;

--
-- Name: gender_id_seq; Type: SEQUENCE OWNED BY; Schema: bookbrainz; Owner: bookbrainz
--

ALTER SEQUENCE gender_id_seq OWNED BY gender.id;

--
-- Name: publisher; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE publisher (
    publisher_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    master_revision_id integer NOT NULL,
    merged_into uuid
);


ALTER TABLE bookbrainz.publisher OWNER TO bookbrainz;

--
-- Name: publisher_data; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE publisher_data (
    publisher_data_id integer NOT NULL,
    name non_empty_presentational_text NOT NULL,
    sort_name non_empty_presentational_text NOT NULL,
    begin_date_year smallint,
    begin_date_month smallint,
    begin_date_day smallint,
    end_date_year smallint,
    end_date_month smallint,
    end_date_day smallint,
    publisher_type_id integer,
    country_id integer,
    comment text DEFAULT ''::text NOT NULL,
    ended boolean DEFAULT false NOT NULL
);


ALTER TABLE bookbrainz.publisher_data OWNER TO bookbrainz;

--
-- Name: publisher_data_publisher_data_id_seq; Type: SEQUENCE; Schema: bookbrainz; Owner: bookbrainz
--

CREATE SEQUENCE publisher_data_publisher_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bookbrainz.publisher_data_publisher_data_id_seq OWNER TO bookbrainz;

--
-- Name: publisher_data_publisher_data_id_seq; Type: SEQUENCE OWNED BY; Schema: bookbrainz; Owner: bookbrainz
--

ALTER SEQUENCE publisher_data_publisher_data_id_seq OWNED BY publisher_data.publisher_data_id;

--
-- Name: publisher_revision; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE publisher_revision (
    revision_id integer NOT NULL,
    publisher_id uuid NOT NULL,
    publisher_tree_id integer NOT NULL
);


ALTER TABLE bookbrainz.publisher_revision OWNER TO bookbrainz;

--
-- Name: publisher_tree; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE publisher_tree (
    publisher_tree_id integer NOT NULL,
    publisher_data_id integer NOT NULL,
    annotation text NOT NULL
);


ALTER TABLE bookbrainz.publisher_tree OWNER TO bookbrainz;

--
-- Name: publisher_tree_publisher_tree_id_seq; Type: SEQUENCE; Schema: bookbrainz; Owner: bookbrainz
--

CREATE SEQUENCE publisher_tree_publisher_tree_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bookbrainz.publisher_tree_publisher_tree_id_seq OWNER TO bookbrainz;

--
-- Name: publisher_tree_publisher_tree_id_seq; Type: SEQUENCE OWNED BY; Schema: bookbrainz; Owner: bookbrainz
--

ALTER SEQUENCE publisher_tree_publisher_tree_id_seq OWNED BY publisher_tree.publisher_tree_id;


--
-- Name: publisher_type; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE publisher_type (
    id integer NOT NULL,
    name presentational_text NOT NULL
);


ALTER TABLE bookbrainz.publisher_type OWNER TO bookbrainz;

--
-- Name: publisher_type_id_seq; Type: SEQUENCE; Schema: bookbrainz; Owner: bookbrainz
--

CREATE SEQUENCE publisher_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bookbrainz.publisher_type_id_seq OWNER TO bookbrainz;

--
-- Name: publisher_type_id_seq; Type: SEQUENCE OWNED BY; Schema: bookbrainz; Owner: bookbrainz
--

ALTER SEQUENCE publisher_type_id_seq OWNED BY publisher_type.id;


--
-- Name: language; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE language (
    id integer NOT NULL,
    iso_code_2t character(3),
    iso_code_2b character(3),
    iso_code_1 character(2),
    iso_code_3 character(3),
    name non_empty_presentational_text NOT NULL,
    frequency natural_integer DEFAULT 0 NOT NULL
);


ALTER TABLE bookbrainz.language OWNER TO bookbrainz;

--
-- Name: language_id_seq; Type: SEQUENCE; Schema: bookbrainz; Owner: bookbrainz
--

CREATE SEQUENCE language_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bookbrainz.language_id_seq OWNER TO bookbrainz;

--
-- Name: language_id_seq; Type: SEQUENCE OWNED BY; Schema: bookbrainz; Owner: bookbrainz
--

ALTER SEQUENCE language_id_seq OWNED BY language.id;

--
-- Name: edition; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE edition (
    edition_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    master_revision_id integer NOT NULL,
    merged_into uuid
);


ALTER TABLE bookbrainz.edition OWNER TO bookbrainz;

--
-- Name: edition_data; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE edition_data (
    edition_data_id integer NOT NULL,
    name non_empty_presentational_text NOT NULL,
    creator_credit_id integer NOT NULL,
    book_id uuid NOT NULL,
    edition_status_id integer,
    country_id integer,
    language_id integer,
    script_id integer,
    date_year smallint,
    date_month smallint,
    date_day smallint,
    barcode character varying(255),
    comment presentational_text DEFAULT ''::text NOT NULL
);


ALTER TABLE bookbrainz.edition_data OWNER TO bookbrainz;

--
-- Name: edition_data_edition_data_id_seq; Type: SEQUENCE; Schema: bookbrainz; Owner: bookbrainz
--

CREATE SEQUENCE edition_data_edition_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bookbrainz.edition_data_edition_data_id_seq OWNER TO bookbrainz;

--
-- Name: edition_data_edition_data_id_seq; Type: SEQUENCE OWNED BY; Schema: bookbrainz; Owner: bookbrainz
--

ALTER SEQUENCE edition_data_edition_data_id_seq OWNED BY edition_data.edition_data_id;


--
-- Name: book; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE book (
    book_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    master_revision_id integer NOT NULL,
    merged_into uuid
);


ALTER TABLE bookbrainz.book OWNER TO bookbrainz;

--
-- Name: book_data; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE book_data (
    book_data_id integer NOT NULL,
    name non_empty_presentational_text NOT NULL,
    creator_credit_id integer NOT NULL,
    book_type_id integer,
    comment presentational_text DEFAULT ''::text NOT NULL
);


ALTER TABLE bookbrainz.book_data OWNER TO bookbrainz;

--
-- Name: book_data_book_data_id_seq; Type: SEQUENCE; Schema: bookbrainz; Owner: bookbrainz
--

CREATE SEQUENCE book_data_book_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bookbrainz.book_data_book_data_id_seq OWNER TO bookbrainz;

--
-- Name: book_data_book_data_id_seq; Type: SEQUENCE OWNED BY; Schema: bookbrainz; Owner: bookbrainz
--

ALTER SEQUENCE book_data_book_data_id_seq OWNED BY book_data.book_data_id;


--
-- Name: book_type; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE book_type (
    id integer NOT NULL,
    name non_empty_presentational_text NOT NULL
);


ALTER TABLE bookbrainz.book_type OWNER TO bookbrainz;

--
-- Name: book_type_id_seq; Type: SEQUENCE; Schema: bookbrainz; Owner: bookbrainz
--

CREATE SEQUENCE book_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bookbrainz.book_type_id_seq OWNER TO bookbrainz;

--
-- Name: book_type_id_seq; Type: SEQUENCE OWNED BY; Schema: bookbrainz; Owner: bookbrainz
--

ALTER SEQUENCE book_type_id_seq OWNED BY book_type.id;

--
-- Name: book_revision; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE book_revision (
    revision_id integer NOT NULL,
    book_id uuid NOT NULL,
    book_tree_id integer NOT NULL
);


ALTER TABLE bookbrainz.book_revision OWNER TO bookbrainz;

--
-- Name: book_tree_book_tree_id_seq; Type: SEQUENCE; Schema: bookbrainz; Owner: bookbrainz
--

CREATE SEQUENCE book_tree_book_tree_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bookbrainz.book_tree_book_tree_id_seq OWNER TO bookbrainz;

--
-- Name: book_tree; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE book_tree (
    book_tree_id integer DEFAULT nextval('book_tree_book_tree_id_seq'::regclass) NOT NULL,
    book_data_id integer NOT NULL,
    annotation text
);


ALTER TABLE bookbrainz.book_tree OWNER TO bookbrainz;

--
-- Name: edition_publisher; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE edition_publisher (
    edition_tree_id integer NOT NULL,
    publisher_id uuid,
    catalog_number non_empty_presentational_text
);


ALTER TABLE bookbrainz.edition_publisher OWNER TO bookbrainz;

--
-- Name: edition_revision; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE edition_revision (
    revision_id integer NOT NULL,
    edition_id uuid NOT NULL,
    edition_tree_id integer NOT NULL
);


ALTER TABLE bookbrainz.edition_revision OWNER TO bookbrainz;

--
-- Name: edition_status; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE edition_status (
    id integer NOT NULL,
    name non_empty_presentational_text NOT NULL
);


ALTER TABLE bookbrainz.edition_status OWNER TO bookbrainz;

--
-- Name: edition_status_id_seq; Type: SEQUENCE; Schema: bookbrainz; Owner: bookbrainz
--

CREATE SEQUENCE edition_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bookbrainz.edition_status_id_seq OWNER TO bookbrainz;

--
-- Name: edition_status_id_seq; Type: SEQUENCE OWNED BY; Schema: bookbrainz; Owner: bookbrainz
--

ALTER SEQUENCE edition_status_id_seq OWNED BY edition_status.id;

--
-- Name: edition_tree; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE edition_tree (
    edition_tree_id integer NOT NULL,
    edition_data_id integer NOT NULL,
    book_id uuid NOT NULL,
    annotation text
);


ALTER TABLE bookbrainz.edition_tree OWNER TO bookbrainz;

--
-- Name: edition_tree_edition_tree_id_seq; Type: SEQUENCE; Schema: bookbrainz; Owner: bookbrainz
--

CREATE SEQUENCE edition_tree_edition_tree_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bookbrainz.edition_tree_edition_tree_id_seq OWNER TO bookbrainz;

--
-- Name: edition_tree_edition_tree_id_seq; Type: SEQUENCE OWNED BY; Schema: bookbrainz; Owner: bookbrainz
--

ALTER SEQUENCE edition_tree_edition_tree_id_seq OWNED BY edition_tree.edition_tree_id;


--
-- Name: revision; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE revision (
    revision_id integer NOT NULL,
    editor_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE bookbrainz.revision OWNER TO bookbrainz;

--
-- Name: revision_parent; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE revision_parent (
    revision_id integer NOT NULL,
    parent_revision_id integer NOT NULL,
    CONSTRAINT revision_parent_check CHECK ((revision_id <> parent_revision_id))
);


ALTER TABLE bookbrainz.revision_parent OWNER TO bookbrainz;

--
-- Name: revision_path; Type: VIEW; Schema: bookbrainz; Owner: bookbrainz
--

CREATE VIEW revision_path AS
    WITH RECURSIVE revision_path(revision_id, parent_revision_id, distance) AS (SELECT revision_parent.revision_id, revision_parent.parent_revision_id, 1 FROM revision_parent UNION SELECT revision_path.revision_id, revision_parent.parent_revision_id, (revision_path.distance + 1) FROM (revision_parent JOIN revision_path ON ((revision_parent.revision_id = revision_path.parent_revision_id)))) SELECT revision_path.revision_id, revision_path.parent_revision_id, revision_path.distance FROM revision_path;


ALTER TABLE bookbrainz.revision_path OWNER TO bookbrainz;

--
-- Name: revision_revision_id_seq; Type: SEQUENCE; Schema: bookbrainz; Owner: bookbrainz
--

CREATE SEQUENCE revision_revision_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bookbrainz.revision_revision_id_seq OWNER TO bookbrainz;

--
-- Name: revision_revision_id_seq; Type: SEQUENCE OWNED BY; Schema: bookbrainz; Owner: bookbrainz
--

ALTER SEQUENCE revision_revision_id_seq OWNED BY revision.revision_id;


--
-- Name: script; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE script (
    id integer NOT NULL,
    iso_code character(4) NOT NULL,
    iso_number character(3) NOT NULL,
    name non_empty_presentational_text NOT NULL,
    frequency natural_integer DEFAULT 0 NOT NULL
);


ALTER TABLE bookbrainz.script OWNER TO bookbrainz;

--
-- Name: script_id_seq; Type: SEQUENCE; Schema: bookbrainz; Owner: bookbrainz
--

CREATE SEQUENCE script_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bookbrainz.script_id_seq OWNER TO bookbrainz;

--
-- Name: script_id_seq; Type: SEQUENCE OWNED BY; Schema: bookbrainz; Owner: bookbrainz
--

ALTER SEQUENCE script_id_seq OWNED BY script.id;


--
-- Name: script_language; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE script_language (
    id integer NOT NULL,
    script integer NOT NULL,
    language integer NOT NULL,
    frequency natural_integer DEFAULT 0 NOT NULL
);


ALTER TABLE bookbrainz.script_language OWNER TO bookbrainz;

--
-- Name: script_language_id_seq; Type: SEQUENCE; Schema: bookbrainz; Owner: bookbrainz
--

CREATE SEQUENCE script_language_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bookbrainz.script_language_id_seq OWNER TO bookbrainz;

--
-- Name: script_language_id_seq; Type: SEQUENCE OWNED BY; Schema: bookbrainz; Owner: bookbrainz
--

ALTER SEQUENCE script_language_id_seq OWNED BY script_language.id;

--
-- Name: url; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE url (
    url_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    master_revision_id integer NOT NULL,
    merged_into uuid
);


ALTER TABLE bookbrainz.url OWNER TO bookbrainz;

--
-- Name: url_data; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE url_data (
    url_data_id integer NOT NULL,
    url non_empty_presentational_text NOT NULL,
    comment presentational_text DEFAULT ''::text NOT NULL
);


ALTER TABLE bookbrainz.url_data OWNER TO bookbrainz;

--
-- Name: url_data_url_data_id_seq; Type: SEQUENCE; Schema: bookbrainz; Owner: bookbrainz
--

CREATE SEQUENCE url_data_url_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bookbrainz.url_data_url_data_id_seq OWNER TO bookbrainz;

--
-- Name: url_data_url_data_id_seq; Type: SEQUENCE OWNED BY; Schema: bookbrainz; Owner: bookbrainz
--

ALTER SEQUENCE url_data_url_data_id_seq OWNED BY url_data.url_data_id;


--
-- Name: url_revision; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE url_revision (
    revision_id integer NOT NULL,
    url_id uuid NOT NULL,
    url_tree_id integer NOT NULL
);


ALTER TABLE bookbrainz.url_revision OWNER TO bookbrainz;

--
-- Name: url_tree; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE url_tree (
    url_tree_id integer NOT NULL,
    url_data_id integer NOT NULL,
    annotation text
);


ALTER TABLE bookbrainz.url_tree OWNER TO bookbrainz;

--
-- Name: url_tree_id_seq; Type: SEQUENCE; Schema: bookbrainz; Owner: bookbrainz
--

CREATE SEQUENCE url_tree_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bookbrainz.url_tree_id_seq OWNER TO bookbrainz;

--
-- Name: url_tree_id_seq; Type: SEQUENCE OWNED BY; Schema: bookbrainz; Owner: bookbrainz
--

ALTER SEQUENCE url_tree_id_seq OWNED BY url_tree.url_tree_id;


--
-- Name: vote; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE vote (
    editor_id integer NOT NULL,
    edit_id integer NOT NULL,
    vote smallint NOT NULL,
    vote_time timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    CONSTRAINT vote_vote_check CHECK ((vote = ANY (ARRAY[(-1), 0, 1])))
);


ALTER TABLE bookbrainz.vote OWNER TO bookbrainz;

--
-- Name: work; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE work (
    work_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    master_revision_id integer NOT NULL,
    merged_into uuid
);


ALTER TABLE bookbrainz.work OWNER TO bookbrainz;

--
-- Name: work_data; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE work_data (
    work_data_id integer NOT NULL,
    name non_empty_presentational_text NOT NULL,
    work_type_id integer,
    comment presentational_text DEFAULT ''::text NOT NULL,
    language_id integer
);


ALTER TABLE bookbrainz.work_data OWNER TO bookbrainz;

--
-- Name: work_data_work_data_id_seq; Type: SEQUENCE; Schema: bookbrainz; Owner: bookbrainz
--

CREATE SEQUENCE work_data_work_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bookbrainz.work_data_work_data_id_seq OWNER TO bookbrainz;

--
-- Name: work_data_work_data_id_seq; Type: SEQUENCE OWNED BY; Schema: bookbrainz; Owner: bookbrainz
--

ALTER SEQUENCE work_data_work_data_id_seq OWNED BY work_data.work_data_id;

--
-- Name: work_revision; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE work_revision (
    revision_id integer NOT NULL,
    work_id uuid NOT NULL,
    work_tree_id integer NOT NULL
);


ALTER TABLE bookbrainz.work_revision OWNER TO bookbrainz;

--
-- Name: work_tree; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE work_tree (
    work_tree_id integer NOT NULL,
    work_data_id integer NOT NULL,
    annotation text
);


ALTER TABLE bookbrainz.work_tree OWNER TO bookbrainz;

--
-- Name: work_tree_id_seq; Type: SEQUENCE; Schema: bookbrainz; Owner: bookbrainz
--

CREATE SEQUENCE work_tree_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bookbrainz.work_tree_id_seq OWNER TO bookbrainz;

--
-- Name: work_tree_id_seq; Type: SEQUENCE OWNED BY; Schema: bookbrainz; Owner: bookbrainz
--

ALTER SEQUENCE work_tree_id_seq OWNED BY work_tree.work_tree_id;


--
-- Name: work_type; Type: TABLE; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE TABLE work_type (
    id integer NOT NULL,
    name non_empty_presentational_text NOT NULL
);


ALTER TABLE bookbrainz.work_type OWNER TO bookbrainz;

--
-- Name: work_type_id_seq; Type: SEQUENCE; Schema: bookbrainz; Owner: bookbrainz
--

CREATE SEQUENCE work_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bookbrainz.work_type_id_seq OWNER TO bookbrainz;

--
-- Name: work_type_id_seq; Type: SEQUENCE OWNED BY; Schema: bookbrainz; Owner: bookbrainz
--

ALTER SEQUENCE work_type_id_seq OWNED BY work_type.id;

--
-- Name: creator_credit_id; Type: DEFAULT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY creator_credit ALTER COLUMN creator_credit_id SET DEFAULT nextval('creator_credit_creator_credit_id_seq'::regclass);


--
-- Name: creator_data_id; Type: DEFAULT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY creator_data ALTER COLUMN creator_data_id SET DEFAULT nextval('creator_data_creator_data_id_seq'::regclass);

--
-- Name: creator_tree_id; Type: DEFAULT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY creator_tree ALTER COLUMN creator_tree_id SET DEFAULT nextval('creator_tree_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY creator_type ALTER COLUMN id SET DEFAULT nextval('creator_type_id_seq'::regclass);

--
-- Name: id; Type: DEFAULT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY country ALTER COLUMN id SET DEFAULT nextval('country_id_seq'::regclass);


--
-- Name: edit_id; Type: DEFAULT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edit ALTER COLUMN edit_id SET DEFAULT nextval('edit_edit_id_seq'::regclass);


--
-- Name: edit_note_id; Type: DEFAULT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edit_note ALTER COLUMN edit_note_id SET DEFAULT nextval('edit_note_edit_note_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY editor ALTER COLUMN id SET DEFAULT nextval('editor_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY editor_preference ALTER COLUMN id SET DEFAULT nextval('editor_preference_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY gender ALTER COLUMN id SET DEFAULT nextval('gender_id_seq'::regclass);

--
-- Name: publisher_data_id; Type: DEFAULT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY publisher_data ALTER COLUMN publisher_data_id SET DEFAULT nextval('publisher_data_publisher_data_id_seq'::regclass);

--
-- Name: publisher_tree_id; Type: DEFAULT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY publisher_tree ALTER COLUMN publisher_tree_id SET DEFAULT nextval('publisher_tree_publisher_tree_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY publisher_type ALTER COLUMN id SET DEFAULT nextval('publisher_type_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY language ALTER COLUMN id SET DEFAULT nextval('language_id_seq'::regclass);

--
-- Name: edition_data_id; Type: DEFAULT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edition_data ALTER COLUMN edition_data_id SET DEFAULT nextval('edition_data_edition_data_id_seq'::regclass);


--
-- Name: book_data_id; Type: DEFAULT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY book_data ALTER COLUMN book_data_id SET DEFAULT nextval('book_data_book_data_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY book_type ALTER COLUMN id SET DEFAULT nextval('book_type_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edition_status ALTER COLUMN id SET DEFAULT nextval('edition_status_id_seq'::regclass);


--
-- Name: edition_tree_id; Type: DEFAULT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edition_tree ALTER COLUMN edition_tree_id SET DEFAULT nextval('edition_tree_edition_tree_id_seq'::regclass);


--
-- Name: revision_id; Type: DEFAULT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY revision ALTER COLUMN revision_id SET DEFAULT nextval('revision_revision_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY script ALTER COLUMN id SET DEFAULT nextval('script_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY script_language ALTER COLUMN id SET DEFAULT nextval('script_language_id_seq'::regclass);

--
-- Name: url_data_id; Type: DEFAULT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY url_data ALTER COLUMN url_data_id SET DEFAULT nextval('url_data_url_data_id_seq'::regclass);


--
-- Name: url_tree_id; Type: DEFAULT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY url_tree ALTER COLUMN url_tree_id SET DEFAULT nextval('url_tree_id_seq'::regclass);


--
-- Name: work_data_id; Type: DEFAULT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY work_data ALTER COLUMN work_data_id SET DEFAULT nextval('work_data_work_data_id_seq'::regclass);

--
-- Name: work_tree_id; Type: DEFAULT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY work_tree ALTER COLUMN work_tree_id SET DEFAULT nextval('work_tree_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY work_type ALTER COLUMN id SET DEFAULT nextval('work_type_id_seq'::regclass);

--
-- Name: creator_credit_name_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY creator_credit_name
    ADD CONSTRAINT creator_credit_name_pkey PRIMARY KEY (creator_credit_id, "position");


--
-- Name: creator_credit_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY creator_credit
    ADD CONSTRAINT creator_credit_pkey PRIMARY KEY (creator_credit_id);


--
-- Name: creator_data_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY creator_data
    ADD CONSTRAINT creator_data_pkey PRIMARY KEY (creator_data_id);

--
-- Name: creator_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY creator
    ADD CONSTRAINT creator_pkey PRIMARY KEY (creator_id);

--
-- Name: creator_revision_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY creator_revision
    ADD CONSTRAINT creator_revision_pkey PRIMARY KEY (revision_id);

--
-- Name: creator_tree_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY creator_tree
    ADD CONSTRAINT creator_tree_pkey PRIMARY KEY (creator_tree_id);


--
-- Name: creator_type_id_key; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY creator_type
    ADD CONSTRAINT creator_type_id_key UNIQUE (id);


--
-- Name: creator_type_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY creator_type
    ADD CONSTRAINT creator_type_pkey PRIMARY KEY (name);

--
-- Name: country_id_key; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY country
    ADD CONSTRAINT country_id_key UNIQUE (id);


--
-- Name: country_name_key; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY country
    ADD CONSTRAINT country_name_key UNIQUE (name);


--
-- Name: country_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY country
    ADD CONSTRAINT country_pkey PRIMARY KEY (iso_code);


--
-- Name: edit_creator_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY edit_creator
    ADD CONSTRAINT edit_creator_pkey PRIMARY KEY (edit_id, revision_id);


--
-- Name: edit_note_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY edit_note
    ADD CONSTRAINT edit_note_pkey PRIMARY KEY (edit_note_id);


--
-- Name: edit_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY edit
    ADD CONSTRAINT edit_pkey PRIMARY KEY (edit_id);


--
-- Name: editor_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY editor
    ADD CONSTRAINT editor_pkey PRIMARY KEY (id);


--
-- Name: editor_preference_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY editor_preference
    ADD CONSTRAINT editor_preference_pkey PRIMARY KEY (id);


--
-- Name: gender_id_key; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY gender
    ADD CONSTRAINT gender_id_key UNIQUE (id);


--
-- Name: gender_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY gender
    ADD CONSTRAINT gender_pkey PRIMARY KEY (name);

--
-- Name: publisher_data_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY publisher_data
    ADD CONSTRAINT publisher_data_pkey PRIMARY KEY (publisher_data_id);

--
-- Name: publisher_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY publisher
    ADD CONSTRAINT publisher_pkey PRIMARY KEY (publisher_id);

--
-- Name: publisher_revision_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY publisher_revision
    ADD CONSTRAINT publisher_revision_pkey PRIMARY KEY (revision_id);

--
-- Name: publisher_tree_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY publisher_tree
    ADD CONSTRAINT publisher_tree_pkey PRIMARY KEY (publisher_tree_id);


--
-- Name: publisher_type_id_key; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY publisher_type
    ADD CONSTRAINT publisher_type_id_key UNIQUE (id);


--
-- Name: publisher_type_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY publisher_type
    ADD CONSTRAINT publisher_type_pkey PRIMARY KEY (name);


--
-- Name: language_iso_code_1_key; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY language
    ADD CONSTRAINT language_iso_code_1_key UNIQUE (iso_code_1);


--
-- Name: language_iso_code_2b_key; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY language
    ADD CONSTRAINT language_iso_code_2b_key UNIQUE (iso_code_2b);


--
-- Name: language_iso_code_2t_key; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY language
    ADD CONSTRAINT language_iso_code_2t_key UNIQUE (iso_code_2t);


--
-- Name: language_iso_code_3_key; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY language
    ADD CONSTRAINT language_iso_code_3_key UNIQUE (iso_code_3);


--
-- Name: language_name_key; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY language
    ADD CONSTRAINT language_name_key UNIQUE (name);


--
-- Name: language_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY language
    ADD CONSTRAINT language_pkey PRIMARY KEY (id);

--
-- Name: edition_data_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY edition_data
    ADD CONSTRAINT edition_data_pkey PRIMARY KEY (edition_data_id);


--
-- Name: book_data_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY book_data
    ADD CONSTRAINT book_data_pkey PRIMARY KEY (book_data_id);


--
-- Name: book_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY book
    ADD CONSTRAINT book_pkey PRIMARY KEY (book_id);


--
-- Name: book_type_id_key; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY book_type
    ADD CONSTRAINT book_type_id_key UNIQUE (id);


--
-- Name: book_type_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY book_type
    ADD CONSTRAINT book_type_pkey PRIMARY KEY (name);

--
-- Name: book_revision_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY book_revision
    ADD CONSTRAINT book_revision_pkey PRIMARY KEY (revision_id);

--
-- Name: book_tree_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY book_tree
    ADD CONSTRAINT book_tree_pkey PRIMARY KEY (book_tree_id);

--
-- Name: edition_publisher_edition_tree_id_publisher_id_catalog_number_key; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY edition_publisher
    ADD CONSTRAINT edition_publisher_edition_tree_id_publisher_id_catalog_number_key UNIQUE (edition_tree_id, publisher_id, catalog_number);

--
-- Name: edition_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY edition
    ADD CONSTRAINT edition_pkey PRIMARY KEY (edition_id);


--
-- Name: edition_revision_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY edition_revision
    ADD CONSTRAINT edition_revision_pkey PRIMARY KEY (revision_id);


--
-- Name: edition_status_id_key; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY edition_status
    ADD CONSTRAINT edition_status_id_key UNIQUE (id);


--
-- Name: edition_status_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY edition_status
    ADD CONSTRAINT edition_status_pkey PRIMARY KEY (name);

--
-- Name: edition_tree_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY edition_tree
    ADD CONSTRAINT edition_tree_pkey PRIMARY KEY (edition_tree_id);


--
-- Name: revision_parent_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY revision_parent
    ADD CONSTRAINT revision_parent_pkey PRIMARY KEY (revision_id, parent_revision_id);


--
-- Name: revision_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY revision
    ADD CONSTRAINT revision_pkey PRIMARY KEY (revision_id);


--
-- Name: script_id_key; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY script
    ADD CONSTRAINT script_id_key UNIQUE (id);


--
-- Name: script_iso_number_key; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY script
    ADD CONSTRAINT script_iso_number_key UNIQUE (iso_number);


--
-- Name: script_language_id_key; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY script_language
    ADD CONSTRAINT script_language_id_key UNIQUE (id);


--
-- Name: script_language_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY script_language
    ADD CONSTRAINT script_language_pkey PRIMARY KEY (script, language);


--
-- Name: script_name_key; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY script
    ADD CONSTRAINT script_name_key UNIQUE (name);


--
-- Name: script_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY script
    ADD CONSTRAINT script_pkey PRIMARY KEY (iso_code);

--
-- Name: url_data_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY url_data
    ADD CONSTRAINT url_data_pkey PRIMARY KEY (url_data_id);


--
-- Name: url_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY url
    ADD CONSTRAINT url_pkey PRIMARY KEY (url_id);


--
-- Name: url_revision_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY url_revision
    ADD CONSTRAINT url_revision_pkey PRIMARY KEY (revision_id);


--
-- Name: url_tree_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY url_tree
    ADD CONSTRAINT url_tree_pkey PRIMARY KEY (url_tree_id);

--
-- Name: work_data_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY work_data
    ADD CONSTRAINT work_data_pkey PRIMARY KEY (work_data_id);

--
-- Name: work_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY work
    ADD CONSTRAINT work_pkey PRIMARY KEY (work_id);

--
-- Name: work_revision_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY work_revision
    ADD CONSTRAINT work_revision_pkey PRIMARY KEY (revision_id);

--
-- Name: work_tree_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY work_tree
    ADD CONSTRAINT work_tree_pkey PRIMARY KEY (work_tree_id);


--
-- Name: work_type_id_key; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY work_type
    ADD CONSTRAINT work_type_id_key UNIQUE (id);


--
-- Name: work_type_pkey; Type: CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

ALTER TABLE ONLY work_type
    ADD CONSTRAINT work_type_pkey PRIMARY KEY (name);

--
-- Name: editor_idx_name; Type: INDEX; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE UNIQUE INDEX editor_idx_name ON editor USING btree (lower((name)::text));


--
-- Name: editor_preference_idx_editor_name; Type: INDEX; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE UNIQUE INDEX editor_preference_idx_editor_name ON editor_preference USING btree (editor, name);


--
-- Name: edition_publisher_edition_tree_id_catalog_number_idx; Type: INDEX; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE UNIQUE INDEX edition_publisher_edition_tree_id_catalog_number_idx ON edition_publisher USING btree (edition_tree_id, catalog_number) WHERE (publisher_id IS NULL);


--
-- Name: edition_publisher_edition_tree_id_publisher_id_idx; Type: INDEX; Schema: bookbrainz; Owner: bookbrainz; Tablespace:
--

CREATE UNIQUE INDEX edition_publisher_edition_tree_id_publisher_id_idx ON edition_publisher USING btree (edition_tree_id, publisher_id) WHERE (catalog_number IS NULL);

--
-- Name: creator_credit_name_creator_credit_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY creator_credit_name
    ADD CONSTRAINT creator_credit_name_creator_credit_id_fkey FOREIGN KEY (creator_credit_id) REFERENCES creator_credit(creator_credit_id);


--
-- Name: creator_credit_name_creator_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY creator_credit_name
    ADD CONSTRAINT creator_credit_name_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES creator(creator_id);

--
-- Name: creator_data_creator_type_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY creator_data
    ADD CONSTRAINT creator_data_creator_type_id_fkey FOREIGN KEY (creator_type_id) REFERENCES creator_type(id);


--
-- Name: creator_data_country_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY creator_data
    ADD CONSTRAINT creator_data_country_id_fkey FOREIGN KEY (country_id) REFERENCES country(id);


--
-- Name: creator_data_gender_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY creator_data
    ADD CONSTRAINT creator_data_gender_id_fkey FOREIGN KEY (gender_id) REFERENCES gender(id);

--
-- Name: creator_master_revision_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY creator
    ADD CONSTRAINT creator_master_revision_id_fkey FOREIGN KEY (master_revision_id) REFERENCES creator_revision(revision_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: creator_merged_into_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY creator
    ADD CONSTRAINT creator_merged_into_fkey FOREIGN KEY (merged_into) REFERENCES creator(creator_id);

--
-- Name: creator_revision_creator_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY creator_revision
    ADD CONSTRAINT creator_revision_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES creator(creator_id);


--
-- Name: creator_revision_creator_tree_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY creator_revision
    ADD CONSTRAINT creator_revision_creator_tree_id_fkey FOREIGN KEY (creator_tree_id) REFERENCES creator_tree(creator_tree_id);


--
-- Name: creator_revision_revision_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY creator_revision
    ADD CONSTRAINT creator_revision_revision_id_fkey FOREIGN KEY (revision_id) REFERENCES revision(revision_id);

--
-- Name: creator_tree_creator_data_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY creator_tree
    ADD CONSTRAINT creator_tree_creator_data_id_fkey FOREIGN KEY (creator_data_id) REFERENCES creator_data(creator_data_id);


--
-- Name: edit_creator_edit_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edit_creator
    ADD CONSTRAINT edit_creator_edit_id_fkey FOREIGN KEY (edit_id) REFERENCES edit(edit_id);


--
-- Name: edit_creator_revision_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edit_creator
    ADD CONSTRAINT edit_creator_revision_id_fkey FOREIGN KEY (revision_id) REFERENCES creator_revision(revision_id);


--
-- Name: edit_publisher_edit_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edit_publisher
    ADD CONSTRAINT edit_publisher_edit_id_fkey FOREIGN KEY (edit_id) REFERENCES edit(edit_id);


--
-- Name: edit_publisher_revision_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edit_publisher
    ADD CONSTRAINT edit_publisher_revision_id_fkey FOREIGN KEY (revision_id) REFERENCES publisher_revision(revision_id);


--
-- Name: edit_note_edit_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edit_note
    ADD CONSTRAINT edit_note_edit_id_fkey FOREIGN KEY (edit_id) REFERENCES edit(edit_id);


--
-- Name: edit_note_editor_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edit_note
    ADD CONSTRAINT edit_note_editor_id_fkey FOREIGN KEY (editor_id) REFERENCES editor(id);

--
-- Name: edit_edition_edit_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edit_edition
    ADD CONSTRAINT edit_edition_edit_id_fkey FOREIGN KEY (edit_id) REFERENCES edit(edit_id);


--
-- Name: edit_book_edit_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edit_book
    ADD CONSTRAINT edit_book_edit_id_fkey FOREIGN KEY (edit_id) REFERENCES edit(edit_id);


--
-- Name: edit_book_revision_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edit_book
    ADD CONSTRAINT edit_book_revision_id_fkey FOREIGN KEY (revision_id) REFERENCES book_revision(revision_id);


--
-- Name: edit_edition_revision_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edit_edition
    ADD CONSTRAINT edit_edition_revision_id_fkey FOREIGN KEY (revision_id) REFERENCES edition_revision(revision_id);


--
-- Name: edit_url_edit_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edit_url
    ADD CONSTRAINT edit_url_edit_id_fkey FOREIGN KEY (edit_id) REFERENCES edit(edit_id);


--
-- Name: edit_url_revision_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edit_url
    ADD CONSTRAINT edit_url_revision_id_fkey FOREIGN KEY (revision_id) REFERENCES url_revision(revision_id);


--
-- Name: edit_work_edit_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edit_work
    ADD CONSTRAINT edit_work_edit_id_fkey FOREIGN KEY (edit_id) REFERENCES edit(edit_id);


--
-- Name: edit_work_revision_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edit_work
    ADD CONSTRAINT edit_work_revision_id_fkey FOREIGN KEY (revision_id) REFERENCES work_revision(revision_id);


--
-- Name: editor_preference_fk_editor; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY editor_preference
    ADD CONSTRAINT editor_preference_fk_editor FOREIGN KEY (editor) REFERENCES editor(id);

--
-- Name: publisher_data_publisher_type_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY publisher_data
    ADD CONSTRAINT publisher_data_publisher_type_id_fkey FOREIGN KEY (publisher_type_id) REFERENCES publisher_type(id);

--
-- Name: publisher_master_revision_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY publisher
    ADD CONSTRAINT publisher_master_revision_id_fkey FOREIGN KEY (master_revision_id) REFERENCES publisher_revision(revision_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: publisher_merged_into_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY publisher
    ADD CONSTRAINT publisher_merged_into_fkey FOREIGN KEY (merged_into) REFERENCES publisher(publisher_id);

--
-- Name: publisher_revision_publisher_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY publisher_revision
    ADD CONSTRAINT publisher_revision_publisher_id_fkey FOREIGN KEY (publisher_id) REFERENCES publisher(publisher_id);


--
-- Name: publisher_revision_publisher_tree_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY publisher_revision
    ADD CONSTRAINT publisher_revision_publisher_tree_id_fkey FOREIGN KEY (publisher_tree_id) REFERENCES publisher_tree(publisher_tree_id);


--
-- Name: publisher_revision_revision_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY publisher_revision
    ADD CONSTRAINT publisher_revision_revision_id_fkey FOREIGN KEY (revision_id) REFERENCES revision(revision_id);

--
-- Name: publisher_tree_publisher_data_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY publisher_tree
    ADD CONSTRAINT publisher_tree_publisher_data_id_fkey FOREIGN KEY (publisher_data_id) REFERENCES publisher_data(publisher_data_id);

--
-- Name: edition_data_country_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edition_data
    ADD CONSTRAINT edition_data_book_id_fkey FOREIGN KEY (book_id) REFERENCES book(book_id);

--
-- Name: edition_data_country_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edition_data
    ADD CONSTRAINT edition_data_country_id_fkey FOREIGN KEY (country_id) REFERENCES country(id);


--
-- Name: edition_data_language_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edition_data
    ADD CONSTRAINT edition_data_language_id_fkey FOREIGN KEY (language_id) REFERENCES language(id);

--
-- Name: edition_data_edition_status_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edition_data
    ADD CONSTRAINT edition_data_edition_status_id_fkey FOREIGN KEY (edition_status_id) REFERENCES edition_status(id);


--
-- Name: edition_data_script_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edition_data
    ADD CONSTRAINT edition_data_script_id_fkey FOREIGN KEY (script_id) REFERENCES script(id);


--
-- Name: book_data_creator_credit_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY book_data
    ADD CONSTRAINT book_data_creator_credit_id_fkey FOREIGN KEY (creator_credit_id) REFERENCES creator_credit(creator_credit_id);

--
-- Name: book_data_book_type_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY book_data
    ADD CONSTRAINT book_data_book_type_id_fkey FOREIGN KEY (book_type_id) REFERENCES book_type(id);


--
-- Name: book_master_revision_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY book
    ADD CONSTRAINT book_master_revision_id_fkey FOREIGN KEY (master_revision_id) REFERENCES book_revision(revision_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: book_merged_into_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY book
    ADD CONSTRAINT book_merged_into_fkey FOREIGN KEY (merged_into) REFERENCES book(book_id);


--
-- Name: book_revision_book_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY book_revision
    ADD CONSTRAINT book_revision_book_id_fkey FOREIGN KEY (book_id) REFERENCES book(book_id);


--
-- Name: book_revision_book_tree_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY book_revision
    ADD CONSTRAINT book_revision_book_tree_id_fkey FOREIGN KEY (book_tree_id) REFERENCES book_tree(book_tree_id);


--
-- Name: book_revision_revision_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY book_revision
    ADD CONSTRAINT book_revision_revision_id_fkey FOREIGN KEY (revision_id) REFERENCES revision(revision_id);

--
-- Name: book_tree_book_data_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY book_tree
    ADD CONSTRAINT book_tree_book_data_id_fkey FOREIGN KEY (book_data_id) REFERENCES book_data(book_data_id);

--
-- Name: edition_publisher_publisher_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edition_publisher
    ADD CONSTRAINT edition_publisher_publisher_id_fkey FOREIGN KEY (publisher_id) REFERENCES publisher(publisher_id);


--
-- Name: edition_publisher_edition_tree_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edition_publisher
    ADD CONSTRAINT edition_publisher_edition_tree_id_fkey FOREIGN KEY (edition_tree_id) REFERENCES edition_tree(edition_tree_id);


--
-- Name: edition_master_revision_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edition
    ADD CONSTRAINT edition_master_revision_id_fkey FOREIGN KEY (master_revision_id) REFERENCES edition_revision(revision_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: edition_merged_into_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edition
    ADD CONSTRAINT edition_merged_into_fkey FOREIGN KEY (merged_into) REFERENCES edition(edition_id);

--
-- Name: edition_revision_edition_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edition_revision
    ADD CONSTRAINT edition_revision_edition_id_fkey FOREIGN KEY (edition_id) REFERENCES edition(edition_id);


--
-- Name: edition_revision_edition_tree_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edition_revision
    ADD CONSTRAINT edition_revision_edition_tree_id_fkey FOREIGN KEY (edition_tree_id) REFERENCES edition_tree(edition_tree_id);


--
-- Name: edition_revision_revision_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edition_revision
    ADD CONSTRAINT edition_revision_revision_id_fkey FOREIGN KEY (revision_id) REFERENCES revision(revision_id);

--
-- Name: edition_tree_edition_data_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edition_tree
    ADD CONSTRAINT edition_tree_edition_data_id_fkey FOREIGN KEY (edition_data_id) REFERENCES edition_data(edition_data_id);


--
-- Name: edition_tree_book_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY edition_tree
    ADD CONSTRAINT edition_tree_book_id_fkey FOREIGN KEY (book_id) REFERENCES book(book_id);


--
-- Name: revision_editor_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY revision
    ADD CONSTRAINT revision_editor_id_fkey FOREIGN KEY (editor_id) REFERENCES editor(id);


--
-- Name: revision_parent_parent_revision_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY revision_parent
    ADD CONSTRAINT revision_parent_parent_revision_id_fkey FOREIGN KEY (parent_revision_id) REFERENCES revision(revision_id);


--
-- Name: revision_parent_revision_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY revision_parent
    ADD CONSTRAINT revision_parent_revision_id_fkey FOREIGN KEY (revision_id) REFERENCES revision(revision_id);


--
-- Name: script_language_language_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY script_language
    ADD CONSTRAINT script_language_language_fkey FOREIGN KEY (language) REFERENCES language(id);


--
-- Name: script_language_script_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY script_language
    ADD CONSTRAINT script_language_script_fkey FOREIGN KEY (script) REFERENCES script(id);

--
-- Name: url_master_revision_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY url
    ADD CONSTRAINT url_master_revision_id_fkey FOREIGN KEY (master_revision_id) REFERENCES url_revision(revision_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: url_merged_into_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY url
    ADD CONSTRAINT url_merged_into_fkey FOREIGN KEY (merged_into) REFERENCES url(url_id);


--
-- Name: url_revision_revision_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY url_revision
    ADD CONSTRAINT url_revision_revision_id_fkey FOREIGN KEY (revision_id) REFERENCES revision(revision_id);


--
-- Name: url_revision_url_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY url_revision
    ADD CONSTRAINT url_revision_url_id_fkey FOREIGN KEY (url_id) REFERENCES url(url_id);


--
-- Name: url_revision_url_tree_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY url_revision
    ADD CONSTRAINT url_revision_url_tree_id_fkey FOREIGN KEY (url_tree_id) REFERENCES url_tree(url_tree_id);


--
-- Name: url_tree_url_data_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY url_tree
    ADD CONSTRAINT url_tree_url_data_id_fkey FOREIGN KEY (url_data_id) REFERENCES url_data(url_data_id);


--
-- Name: vote_edit_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY vote
    ADD CONSTRAINT vote_edit_id_fkey FOREIGN KEY (edit_id) REFERENCES edit(edit_id);


--
-- Name: vote_editor_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY vote
    ADD CONSTRAINT vote_editor_id_fkey FOREIGN KEY (editor_id) REFERENCES editor(id);

--
-- Name: work_data_language_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY work_data
    ADD CONSTRAINT work_data_language_id_fkey FOREIGN KEY (language_id) REFERENCES language(id);

--
-- Name: work_data_work_type_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY work_data
    ADD CONSTRAINT work_data_work_type_id_fkey FOREIGN KEY (work_type_id) REFERENCES work_type(id);


--
-- Name: work_master_revision_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY work
    ADD CONSTRAINT work_master_revision_id_fkey FOREIGN KEY (master_revision_id) REFERENCES work_revision(revision_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: work_merged_into_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY work
    ADD CONSTRAINT work_merged_into_fkey FOREIGN KEY (merged_into) REFERENCES work(work_id);

--
-- Name: work_revision_revision_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY work_revision
    ADD CONSTRAINT work_revision_revision_id_fkey FOREIGN KEY (revision_id) REFERENCES revision(revision_id);


--
-- Name: work_revision_work_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY work_revision
    ADD CONSTRAINT work_revision_work_id_fkey FOREIGN KEY (work_id) REFERENCES work(work_id);


--
-- Name: work_revision_work_tree_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY work_revision
    ADD CONSTRAINT work_revision_work_tree_id_fkey FOREIGN KEY (work_tree_id) REFERENCES work_tree(work_tree_id);

--
-- Name: work_tree_work_data_id_fkey; Type: FK CONSTRAINT; Schema: bookbrainz; Owner: bookbrainz
--

ALTER TABLE ONLY work_tree
    ADD CONSTRAINT work_tree_work_data_id_fkey FOREIGN KEY (work_data_id) REFERENCES work_data(work_data_id);


--
-- PostgreSQL database dump complete
--

